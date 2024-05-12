const battery = await Service.import("battery");

export default function RRight() {
  return Widget.Box({
    className: "telemetery",
    spacing: 11,
    children: [Memory(), Battery()],
  });
}

const divide = ([total, free]) => free / total;

const cpu = Variable(0, {
  poll: [
    2000,
    "top -b -n 1",
    (out) =>
      divide([
        100,
        out
          .split("\n")
          .find((line) => line.includes("Cpu(s)"))
          .split(/\s+/)[1]
          .replace(",", "."),
      ]),
  ],
});

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

const cpuProgress = Widget.CircularProgress({
  value: cpu.bind(),
});

function Memory() {
  return Widget.Overlay({
    className: "memory",
    child: Widget.CircularProgress({
      value: ram.bind(),
    }),
    overlays: [
      Widget.Label({
        className: "circle-text",
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
