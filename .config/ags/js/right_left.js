const systemtray = await Service.import("systemtray");
const hyprland = await Service.import("hyprland");
const notifications = await Service.import("notifications");

import { NotificationsCount } from "./notifications.js";

// global spacing for this whole block
const spacing = 13;

export default function RLeft() {
  return Widget.Box({
    className: "user_info",
    spacing,
    children: [TrayAndLayout(), UpdatesWeatherAndNotifs()],
  });
}

function TrayAndLayout() {
  const revealTray = systemtray.bind("items").as((i) => i.length > 0);

  return Widget.Box({
    spacing: systemtray.bind("items").as((i) => (i.length > 0 ? spacing : 0)),
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

function UpdatesWeatherAndNotifs() {
  return Widget.Box({
    spacing: notifications
      .bind("notifications")
      .as((c) => (c.filter((n) => !n.transient).length > 0 ? spacing : 0)),
    children: [WeatherAndUpdates(), NotificationsCount()],
  });
}

function WeatherAndUpdates() {
  const updatesCount = Variable("~", {
    poll: [
      60 * 60 * 1000, // once an hour
      ["bash", "-c", "checkupdates | wc -l"],
    ],
  });

  // const weather = Utils.fetch('http://wttr.in/?format=3')
  //   .then(res => res.text())
  //   .then(print)
  //   .catch(console.error)

  const weather = Variable("···", {
    poll: [
      60 * 60 * 1000,
      ["bash", "-c", "~/dotfiles/.config/ags/scripts/weather"],
      (out) => {
        if (out.length > 8)
          return "󰒏"; // length more than 8 is an error from server
        else if (out.length > 0) return out;
        return "···";
      },
    ],
  });

  const packageIcon = "󰏗 "; //   󰏗

  return Widget.Overlay({
    className: "weather_and_updates",
    child: Widget.Box({
      vertical: true,
      children: [
        Widget.Label({ label: weather.bind() }),
        Widget.Label({ label: updatesCount.bind().as((u) => packageIcon + u) }),
      ],
    }),
    overlays: [
      Widget.Separator({
        vertical: false,
        vpack: "center",
      }),
    ],
  });
}
