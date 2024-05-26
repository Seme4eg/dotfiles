const battery = await Service.import("battery");

export default function RRight() {
  return Widget.Box({
    className: "telemetery",
    spacing: 11,
    children: [CPU(), Memory(), Battery()],
  });
}

const divide = ([total, free]) => free / total;

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
        if (copy.length >= historyLen) copy.shift();
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
        let temp = Number(JSON.parse(out)["acpitz-acpi-0"].temp1.temp1_input);
        return `${temp.toFixed(0)}°`;
      },
    ],
  });

  return Widget.Box({
    className: "cpu",
    vertical: true,
    // vpack: "center",
    children: [
      Widget.Box({
        className: "label",
        // vpack: "start",
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
            // TODO: rewrite to levelbar
            Widget.ProgressBar({
              vertical: true,
              inverted: true,
              value: load,
            }),
          ),
        ),
      }),
    ],
  });
}

function Memory() {
  const ram = Variable(0, {
    poll: [
      2000,
      "free",
      (out) =>
        divide(
          out
            .split("\n")
            .find((line) => line.includes("Mem:"))
            .split(/\s+/)
            .splice(1, 2),
        ),
    ],
  });

  return Widget.Overlay({
    className: "memory",
    child: Widget.CircularProgress({
      value: ram.bind(),
    }),
    overlays: [
      Widget.Label({
        className: "circle_text",
        label: "󰍛",
      }),
    ],
  });
}

function Battery() {
  const classStr = Utils.merge(
    [battery.bind("charging"), battery.bind("percent")],
    (c, p) => "percent " + (c ? "charging" : p <= 15 ? "low" : ""),
  );

  const TimeRemaining = (css = "") =>
    Widget.Label({
      hpack: "start",
      css: css,
      className: "time_remaining",
      label: battery
        .bind("time_remaining")
        .as((t) => `${(t / 60).toFixed(0)}m`),
    });

  return Widget.Box({
    visible: battery.bind("available"),
    className: "battery",
    children: [
      Widget.Box({
        className: classStr,
        spacing: 0,
        children: [
          Widget.Label({
            label: battery.bind("percent").as(String),
          }),
          Widget.Label({
            className: "icon",
            label: "󱐋",
          }),
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
