const audio = await Service.import("audio");
const bluetooth = await Service.import("bluetooth");
const network = await Service.import("network");

export default function RCenter() {
  return Widget.Box({
    className: "sys_info",
    spacing: 10,
    children: [Network(), AudioBlock(), BacklightAndBt()],
  });
}

function Network() {
  return Widget.Box({
    className: "network",
    children: [VPN(), IfDisconnected(), IfConnected()],
  });
}

function IfDisconnected() {
  return Widget.Revealer({
    transition: "slide_right",
    transitionDuration: 350,
    // "unknown" | "none" | "portal" | "limited" | "full"
    revealChild: network.bind("connectivity")
      .as((status) => status === "none" || status === "portal"),
    child: Widget.Label({
      className: "disconnected",
      label: network.bind("connectivity")
        .as((status) => status === "portal" ? "󰤩" : "󰤮")
    }),
  });
}

function IfConnected() {
  const isConnected = network
    .bind("connectivity")
    .as((status) => status === "limited" || status === "full");

  const bandwidth = Variable(
    { up: 0, upBold: false, down: 0, downBold: false },
    {
      poll: [
        1000,
        ["bash", "-c", App.configDir + "/scripts/bandwidth"],
        (out) => {
          let upBold = false;
          let downBold = false;
          let [down, up] = out.split(" ").map((v, i) => {
            v = v / 1024;
            if (v > 1024) {
              if (i === 0) downBold = true;
              else upBold = true;
              v = v / 1024;
            }
            return v.toFixed(0);
          });
          return { up, down, upBold, downBold };
        },
      ],
    },
  );

  // connected widget
  // FIXME: maybe im dumb, cuz can't understand how to make that revealer
  // work. ProgressBar width fucs everything up
  return Widget.Revealer({
    className: "connected",
    revealChild: isConnected,
    transitionDuration: 350,
    child: Widget.Overlay({
      child: Widget.ProgressBar({
        widthRequest: network
          .bind("connectivity")
          .as((status) => (status === "limited" || status === "full" ? 38 : 0)),
        vpack: "center",
        value: network.bind("primary").as((type) => {
          if (type === "wifi") {
            return network[type].strength / 100;
          } else return 1;
        }),
      }),
      overlays: [
        Widget.Label({
          className: bandwidth.bind().as((b) => "up " + (b.upBold && "bold")),
          label: bandwidth.bind().as((b) => " " + b.up),
        }),
        Widget.Label({
          className: bandwidth
            .bind()
            .as((b) => "down " + (b.downBold && "bold")),
          label: bandwidth.bind().as((b) => " " + b.down),
        }),
      ],
    }),
  });
}

function VPN() {
  return Widget.Revealer({
    transition: "slide_left",
    transitionDuration: 350,
    revealChild: network.vpn
      .bind("activated_connections")
      .as((c) => c.length > 0),
    child: Widget.Icon({
      className: "vpn",
      icon: network.vpn.bind("activated_connections").as((cons) => {
        if (cons.length > 0) return cons[0].icon_name;
        return "";
      }),
    }),
  });
}

// IDEA: wpctl inspect @DEFAULT_SINK@
// https://aylur.github.io/ags-docs/services/audio/
// find:
//   bluetooth: media.name / node.description
//   not: alsa.card_name, alsa.mixer_name, alsa_name
// maybe somehow use 'node.name'? present always
function AudioBlock() {
  return Widget.Box({
    className: "audio",
    spacing: 7,
    children: [Sink(), Source()],
  });
}

function Sink() {
  const classStr = audio.speaker.bind("name").as((n) => `sink ${n}`);

  return Widget.Box({
    className: classStr,
    children: [
      Widget.Label({
        className: "level",
        label: audio.speaker.bind("volume").as((v) => (v * 100).toFixed(0)),
      }),
      Widget.Label({
        className: "icon",
        // TODO:
        // if [[ "$(node_name)" == *"EDIFIER_S880DB"* ]]; then
        //   is_muted "SINK" && echo 󰓄 || echo 󰓃
        // else is_muted "SINK" && echo 󰟎 || echo
        label: audio.speaker.bind("is_muted").as((b) => (b ? "󰟎" : "󰋋")),
      }),
    ],
  });
}

function Source() {
  return Widget.Box({
    className: "source",
    children: [
      Widget.Label({
        className: "level",
        label: audio.microphone.bind("volume").as((v) => (v * 100).toFixed(0)),
      }),
      Widget.Label({
        className: "icon",
        label: audio.microphone.bind("is_muted").as((b) => (b ? "" : "")),
      }),
    ],
  });
}

function BacklightAndBt() {
  return Widget.Box({ children: [Backlight(), Bluetooth()] });
}

function Backlight() {
  let brightness = Variable("0", {
    listen: [
      ["bash", "-c", App.configDir + "/scripts/backlight"],
      (out) => out / 100,
    ],
  });

  return Widget.Overlay({
    className: "backlight",
    child: Widget.CircularProgress({ value: brightness.bind() }),
    overlays: [Widget.Label({ className: "circle_text", label: "󰃝" })],
  });
}

function Bluetooth() {
  return Widget.Box({
    className: "bluetooth",
    children: [
      Widget.Revealer({
        transition: "slide_right",
        transitionDuration: 350,
        revealChild: bluetooth.bind("enabled").as((e) => !e),
        child: Widget.Label({
          className: "disabled",
          label: bluetooth.bind("enabled").as((s) => (s ? "󰂯" : "󰂲")),
        }),
      }),
      Widget.Revealer({
        transition: "slide_right",
        transitionDuration: 350,
        revealChild: bluetooth
          .bind("connected_devices")
          .as((d) => d.length > 0),
        child: Widget.Box({
          className: "devices_block",
          spacing: 5,
          setup: (self) =>
            self.hook(
              bluetooth,
              (self) => {
                self.children = bluetooth.connected_devices.map(BtDevice);
                self.visible = bluetooth.connected_devices.length > 0;
              },
              "notify::connected-devices",
            ),
        }),
      }),
    ],
  });
}

/** @param {import('resource:///com/github/Aylur/ags/service/bluetooth.js').BluetoothDevice} device */
function BtDevice(device) {
  return Widget.Box({
    className: "device",
    children: [
      Widget.Icon(device.icon_name + "-symbolic"),
      Widget.ProgressBar({
        vertical: true,
        inverted: true,
        value: device.bind("battery_percentage").as((p) => p / 100),
      }),
    ],
  });
}
