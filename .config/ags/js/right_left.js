const systemtray = await Service.import("systemtray");
const hyprland = await Service.import("hyprland");
const notifications = await Service.import("notifications");

import { NotificationsCount } from "./notifications.js";

export default function RLeft() {
  return Widget.Box({
    className: "user_info",
    spacing: 9,
    children: [TrayAndLayout(), Updates(), WeatherAndNotifs()],
  });
}

function test() {
  return Widget.Slider({
    vertical: false,
  });
}

function TrayAndLayout() {
  const revealTray = systemtray.bind("items").as((i) => i.length > 0);

  return Widget.Box({
    spacing: systemtray.bind("items").as((i) => (i.length > 0 ? 11 : 0)),
    // hexpand; false,
    children: [SysTray(revealTray), Layout()],
  });
}

function SysTray(reveal) {
  /** @param {import('types/service/systemtray').TrayItem} item */
  const SysTrayItem = (item) =>
    Widget.Button({
      child: Widget.Icon({ size: 18 }).bind("icon", item, "icon"),
      tooltipMarkup: item.bind("tooltip_markup"),
      onPrimaryClick: (_, event) => item.openMenu(event),
    });

  return Widget.Revealer({
    transition: "slide_left",
    transitionDuration: 350,
    revealChild: reveal,
    child: Widget.Box({
      spacing: 5,
      className: "tray",
      children: systemtray.bind("items").as((i) => i.map(SysTrayItem)),
    }),
  });
}

function Layout() {
  const DEFAULT_KB = "at-translated-set-2-keyboard";

  return Widget.Label({
    className: "layout",
  }).hook(
    hyprland,
    (self, _, layout) => {
      // TODO: rewrite on watcher when https://github.com/Aylur/ags/issues/414
      // will be resolved
      if (!layout) {
        let obj = Utils.exec("hyprctl devices -j");
        let keyboards = JSON.parse(obj)["keyboards"];
        let kb = keyboards.find((val) => val.name === DEFAULT_KB);
        layout = kb["active_keymap"];
      }
      self.label = String(layout).slice(0, 2).toUpperCase();
    },
    "keyboard-layout",
  );
}

function Updates() {
  const updatesCount = Variable("~", {
    poll: [
      60 * 60 * 1000, // once an hour
      ["bash", "-c", "checkupdates | wc -l"],
    ],
  });

  return Widget.Overlay({
    className: "updates",
    child: Widget.Label({
      className: updatesCount
        .bind()
        .as((u) => (Number(u) > 99 ? "fg small" : "fg")),
      label: updatesCount.bind().as(String),
    }),
    overlays: [
      Widget.Label({
        className: "bg",
        label: "",
      }),
    ],
  });
}

function WeatherAndNotifs() {
  return Widget.Box({
    className: "notifs",
    spacing: notifications
      .bind("notifications")
      .as((c) => (c.filter((n) => !n.transient).length > 0 ? 10 : 0)),
    children: [Weather(), NotificationsCount()],
  });
}

function Weather() {
  // const weather = Utils.fetch('http://wttr.in/?format=3')
  //   .then(res => res.text())
  //   .then(print)
  //   .catch(console.error)

  const weather = Variable(undefined, {
    poll: [
      60 * 60 * 1000,
      ["bash", "-c", "~/dotfiles/.config/ags/scripts/weather"],
      // if weather length is more than 8 its an error from server
      (out) => {
        if (out.length > 8) return "󰒏";
        else if (out.length > 0) return out;
      },
    ],
  });

  const child = weather.bind().as((w) => {
    if (w)
      return Widget.Label({
        className: "weather",
        label: w,
      });
    return Widget.Spinner();
  });

  return Widget.Box({
    child: child,
  });
}
