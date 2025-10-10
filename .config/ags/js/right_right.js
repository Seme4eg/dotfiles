const battery = await Service.import("battery");

export default function RRight() {
  return Widget.Box({
    className: "telemetery",
    spacing: 11,
    children: [CPU(), Memory(), Battery()],
  });
}

function CPU() {
  const historyLen = 17;

  const cpu = Variable(Array(historyLen).fill(0), {
    poll: [
      2000,
      // In 'top' output there are 3 columns that we need:
      // - "us": Percentage of CPU time spent on user processes (non-kernel code).
      // - "sy": Percentage of CPU time spent on system processes (kernel code).
      // - "ni": Percentage of CPU time spent on user processes with a positive nice value (lower priority).
      // so we sum those up and get current cpu usage
      ["bash", "-c", "top -b -n 1 | grep %Cpu | awk '{print $2 + $4 + $6}'"],
      (out) => {
        const load = out / 100;
        let copy = cpu.getValue();
        copy.shift();
        copy.push(load);
        cpu.setValue(copy);
        return copy;
      },
    ],
  });

  const cpuTemp = Variable("40", {
    poll: [
      2000,
      "sensors -j",
      (out) => {
        let temp = Number(
          JSON.parse(out)["coretemp-isa-0000"]["Package id 0"].temp1_input
        );
        return `${temp.toFixed(0)}°`;
      },
    ],
  });

  return Widget.Box({
    className: "cpu",
    vertical: true,
    children: [
      Widget.Box({
        className: "label",
        children: [
          Widget.Label({ className: "text", label: "cpu" }),
          Widget.Label({
            className: "value",
            hexpand: true,
            hpack: "end",
            label: cpuTemp.bind(),
          }),
        ],
      }),
      Widget.Box({
        vexpand: true,
        children: cpu.bind().as((loads) =>
          loads.map((load) =>
            Widget.LevelBar({
              vertical: true,
              inverted: true,
              value: load,
            })
          )
        ),
      }),
    ],
  });
}

function Memory() {
  // @what either 'Mem' or 'Swap', @from is the output of 'free' command
  const get = (what, from) =>
    from
      .split("\n")
      .find((line) => line.includes(what + ":"))
      .split(/\s+/);

  // Ram value for laptops with less ram to not display 'cached' mem
  // const ram = Variable(0, {
  //   poll: [
  //     2000,
  //     "free",
  //     (out) => {
  //       // returns total, used, free, shared and cache respectively
  //       let ram = get("Mem", out).splice(1, 5);

  //       // divide (used - cached) by total
  //       return (ram[1] - ram[4]) / ram[0];
  //     },
  //   ],
  // });

  const ram = Variable(0, {
    poll: [
      2000,
      "free",
      (out) => {
        let ram = get("Mem", out).splice(1, 2); // returns total and used respectively

        return ram[1] / ram[0]; // divide used by total, excluding zram
      },
    ],
  });


  return Widget.Overlay({
    className: "memory",
    child: Widget.CircularProgress({ value: ram.bind() }),
    overlays: [Widget.Label({ className: "circle_text", label: "󰍛" })],
  });
}

function Battery() {
  const classStr = Utils.merge(
    [battery.bind("charging"), battery.bind("percent")],
    (c, p) => "percent " + (c ? "charging" : p <= 15 ? "low" : "")
  );

  const TimeRemaining = (css = "") =>
    Widget.Label({
      hpack: "start",
      css: css,
      className: "time_remaining",
      label: battery
        .bind("time_remaining")
        .as((t) => {
          let remaining = (t / 60).toFixed(0)
          if (remaining > 999) remaining = ' '
          return remaining + 'm'
        }),
    });

  return Widget.Box({
    visible: battery.bind("available"),
    className: "battery",
    children: [
      Widget.Box({
        className: classStr,
        spacing: 0,
        children: [
          Widget.Label({ label: battery.bind("percent").as(String), }),
          Widget.Label({ className: "icon", label: "󱐋", }),
        ],
      }),
      Widget.Separator(),
      // using overlay here to not extend the height of the bar
      Widget.Overlay({
        className: "info",
        // passing a copy of time widget here to not hardcode the widget width
        child: TimeRemaining("color: transparent;"),
        overlays: [
          Widget.Label({
            hpack: "start",
            className: "energy_rate",
            label: battery.bind("energy_rate").as((w) => `${w.toFixed(0)}W`),
          }),
          TimeRemaining(),
        ],
      }),
    ],
  });
}
