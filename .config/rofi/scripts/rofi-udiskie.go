package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"runtime/debug"
	"strings"
)

var mountedPrefixes = map[string]string{
	"True":  "☑ ",
	"False": "☐ ",
}

type Device struct {
	// "True" / "False"
	Mounted  string `json:"mounted"`
	Loop     string `json:"loop"`
	Luks     string `json:"luks"`
	HasMedia string `json:"hasMedia"`

	DevPath    string `json:"devPath"` // /dev/loop*, /dev/sd*, ..
	Label      string `json:"idLabel"`
	MounthPath string `json:"mountPath"` // ie /run/media/<uname>/<idLabel>
	UiLabel    string `json:"uiLabel"`   // /dev/sda: USB DISK 3.0
}

func (d Device) Format() string {
	return `{{"mounted": "{is_mounted}", "loop": "{is_loop}", "luks": "{is_luks}", "hasMedia": "{has_media}", "devPath": "{device_file}", "idLabel": "{id_label}", "mountPath": "{mount_path}", "uiLabel": "{ui_device_label}"}}`
}

func main() {
	var (
		err error
		ret = 0 // return code
	)

	defer func() {
		if rec := recover(); rec != nil {
			fmt.Println(rec)
			debug.PrintStack()
		}
		os.Exit(ret)
	}()

	// execute immediately
	out, err := exec.Command("udiskie-info", "-C", "-a", "-o", Device{}.Format()).Output()
	if err != nil {
		fmt.Println("command exec error: ", err.Error())
		ret = 1
		return
	}

	if len(out) == 0 {
		NotifyError("Nothing to (un)mount")
		return
	}

	devices, err := Parse(out)
	if err != nil {
		fmt.Println("parse error: ", err.Error())
		ret = 1
		return
	}
	if len(devices) == 0 {
		NotifyError("Nothing to (un)mount")
		return
	}

	options := Prettify(devices)
	device, err := GetSelection(options, devices)
	if err != nil {
		fmt.Println("menu error: ", err)
		ret = 1
		return
	}

	// if user selected /dev/sda - the drive itself, not the partition
	if device.HasMedia == "True" {
		// find its partition
		for key, d := range devices {
			if key != device.DevPath && strings.HasPrefix(key, device.DevPath) {
				device = d
				break
			}
		}
	}

	err = HandleSelection(device) // mount / unmount device
	if err != nil {
		ret = 1
		return
	}
}

// parses 'udiskie-info' command output line by line, unmarshals it and
// returns filtered devices list. Filters luks and loop devices (ie snaps) out.
// keys in returned map are device paths (ie /dev/sd*)
func Parse(output []byte) (map[string]Device, error) {
	devices := make(map[string]Device)

	for _, line := range strings.Split(strings.TrimSpace(string(output)), "\n") {
		var device Device
		err := json.Unmarshal([]byte(line), &device)
		if err != nil {
			return nil, err
		}

		// filter snaps, luks mounts and temporary devices like waydroid mounts
		if device.Loop == "True" || device.Luks == "True" {
			continue
		}

		devices[device.DevPath] = device
	}
	return devices, nil
}

// translates devices map into lines for rofi, prepends each partition with
// corresponding indicative prefix
func Prettify(devices map[string]Device) (out string) {
	// here might also be some 'alignment' code that adds extra spaces so things
	// are in column
	for _, d := range devices {
		out += MountedPrefix(d, devices) + d.UiLabel + " " + d.MounthPath + "\n"
	}
	return strings.TrimSpace(out)
}

func MountedPrefix(device Device, devices map[string]Device) (prefix string) {
	// check if device has partitions and has them mounted
	if device.HasMedia == "True" {
		for _, d := range devices {
			if strings.HasPrefix(d.DevPath, device.DevPath) && d.DevPath != device.DevPath {
				return mountedPrefixes[d.Mounted]
			}
		}
	}
	return mountedPrefixes[device.Mounted]
}

func NotifyError(message string) {
	err := exec.Command("notify-send", "-e", "udiskie-script", message).Run()
	if err != nil {
		fmt.Println(err)
		panic("something went terribly wrong, sir")
	}
}

// runs rofi, gets selection string from its stdout, finds matching device
// in 'devices' and returns it
func GetSelection(options string, devices map[string]Device) (device Device, err error) {
	echo := exec.Command("echo", "-e", options)
	menu := exec.Command("rofi", "-dmenu", "-i")
	menu.Stdin, err = echo.StdoutPipe() // pipe echo stdout to rofi stdin
	if err != nil {
		return Device{}, err
	}
	var out bytes.Buffer
	menu.Stdout = &out

	if err := echo.Start(); err != nil {
		return Device{}, err
	}
	if err := menu.Start(); err != nil {
		return Device{}, err
	}
	if err := echo.Wait(); err != nil {
		return Device{}, err
	}
	if err := menu.Wait(); err != nil {
		return Device{}, err
	}

	devPath := strings.Split(out.String(), ":")[0]
	// Strip leading mounted status icon.
	// Since device and therefore its mounted status aren't known, try to remove
	// both possible prefixes. (another solution was to remove utf.runelen + 1
	// but it would have brought yet another dependency)
	for _, v := range mountedPrefixes {
		devPath = strings.TrimPrefix(devPath, v)
	}
	device, ok := devices[devPath]
	if !ok {
		return Device{}, fmt.Errorf("no device with following device path found: %s", devPath)
		// return Device{}, errors.New("no device with following device path found: " + devPath)
	}

	return device, nil
}

// mounts / unmounts device based on its mount path and label
func HandleSelection(device Device) error {
	if device.MounthPath != "" {
		err := exec.Command("udiskie-umount", device.MounthPath).Run()
		if err != nil {
			fmt.Println("unmount error: ", err)
			NotifyError("Unmount error")
			return err
		}
	} else if device.Label != "" {
		err := exec.Command("udiskie-mount", device.DevPath).Run()
		if err != nil {
			fmt.Println("mount error: ", err)
			NotifyError("Mount error")
			return nil
		}
	} else {
		NotifyError("Unknown device - aborting")
		return nil
	}
	return nil
}
