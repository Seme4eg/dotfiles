const systemtray = await Service.import("systemtray");
const hyprland = await Service.import("hyprland");

// global spacing for this whole block
const spacing = 13;

export default function RLeft() {
  return Widget.Box({
    className: "user_info",
    spacing,
    children: [TrayAndLayout(), UpdatesAndNotifs()],
  });
}

function TrayAndLayout() {
  const revealTray = systemtray.bind("items").as((i) => i.length > 0);

  return Widget.Box({
    spacing: systemtray.bind("items").as((i) => (i.length > 0 ? spacing : 0)),
    // hexpand; false,
    children: [SysTray(revealTray), LayoutAndSubmap()],
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
      children: systemtray
        .bind("items")
        .as((i) => i.filter((i) => i.id).map(SysTrayItem)),
    }),
  });
}

function LayoutAndSubmap() {
  return Widget.Box({
    className: "network",
    vertical: true,
    vpack: "center",
    children: [Layout(), Submap()],
  });
}

function Layout() {
  const DEFAULT_KB = "at-translated-set-2-keyboard";

  return Widget.Label({
    className: "layout",
  }).hook(
    hyprland,
    (self, _, layout) => {
      // FIXME: https://github.com/Aylur/ags/issues/414
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

function Submap() {
  const _submap = Variable("");

  return Widget.Revealer({
    transition: "slide_down",
    transitionDuration: 250,
    revealChild: _submap.bind().as((s) => s !== ""),
    child: Widget.Label({
      className: "submap",
      label: _submap.bind(),
    }),
    // FIXME: https://github.com/Aylur/ags/issues/414
  }).hook(hyprland, (_, submap) => _submap.setValue(submap), "submap");
}

function UpdatesAndNotifs() {
  let notif_count = Variable(0, {
    listen: [
      ["bash", "-c", "swaync-client -s"], // subscribe to swaync events
      (out) => +JSON.parse(out).count,
    ],
  });

  return Widget.Box({
    spacing: notif_count.bind().as(c => Number(c) > 0 ? spacing : 0),
    children: [Updates(), NotificationsCount(notif_count)],
  });
}

// NOTE: do NOT import the notifications service of ags, it will start the ags
//  notif daemon, which will break swaync
export function NotificationsCount(notif_count) {
  return Widget.Revealer({
    revealChild: notif_count.bind().as(c => c > 0),
    transition: "slide_right",
    transitionDuration: 350,
    child: Widget.Overlay({
      className: "notification_counter",
      child: Widget.Label({
        className: "fg",
        label: notif_count.bind().as(String)
      }),
      overlays: [
        Widget.Label({ className: "bg", vpack: "center", label: "󱥂", }),
      ],
    }),
  });
}

function Updates() {
  const updatesCount = Variable("~", {
    poll: [
      60 * 60 * 1000, // once an hour
      ["bash", "-c", "checkupdates | wc -l"],
    ],
  });

  const packageIcon = "󰏗 "; //   󰏗

  return Widget.Overlay({
    className: "updates",
    child: Widget.Box({
      // vertical: true,
      hpack: "center",
      children: [
        Widget.Label({
          label: updatesCount.bind().as((u) => packageIcon + u),
        }),
      ],
    }),
  });
}
