// we don't need dunst or any other notification daemon
// because the Notifications module is a notification daemon itself

import GLib from "gi://GLib";
import Pango from "gi://Pango";

const notifications = await Service.import("notifications");

export function NotificationsCount() {
  return Widget.Revealer({
    revealChild: notifications
      .bind("notifications")
      .as((c) => c.filter((n) => !n.transient).length > 0),
    transition: "slide_right",
    transitionDuration: 350,
    child: Widget.Overlay({
      className: "notification_counter",
      child: Widget.Label({
        className: "fg",
        label: notifications
          .bind("notifications")
          .as((c) => String(c.filter((n) => !n.transient).length)),
      }),
      overlays: [
        Widget.Label({
          className: "bg",
          label: "󱥂",
        }),
      ],
    }),
  });
}

/** @param {import('resource:///com/github/Aylur/ags/service/notifications.js').Notification} n */
function NotificationIcon({ app_entry, app_icon, image }) {
  if (image) {
    return Widget.Box({
      css:
        `background-image: url("${image}");` +
        "background-size: contain;" +
        "background-repeat: no-repeat;" +
        "background-position: center;",
    });
  }

  let icon = "dialog-information-symbolic";
  if (Utils.lookUpIcon(app_icon)) icon = app_icon;

  if (app_entry && Utils.lookUpIcon(app_entry)) icon = app_entry;

  return Widget.Box({
    child: Widget.Icon(icon),
  });
}

/** @param {import('resource:///com/github/Aylur/ags/service/notifications.js').Notification} n */
function Notification(n, /** @type Boolean */ showTime = false) {
  // ["id", "summary", "time", "popup", "urgency", "resident", "category"].forEach(
  //   (key) => {
  //     print(key, n[key]);
  //   },
  // );

  const icon = Widget.Box({
    vpack: "start",
    className: "icon",
    child: NotificationIcon(n),
  });

  function getTimePassed(/** @type {number} */ notificationTime) {
    if (!showTime) return "";
    return GLib.DateTime.new_from_unix_local(notificationTime).format(
      "%H ⍿ %M",
    );
  }

  const title = Widget.Box({
    children: [
      Widget.Label({
        className: "title",
        xalign: 0,
        justification: "left",
        maxWidthChars: 20,
        ellipsize: true,
        truncate: "end",
        label: n.summary,
        use_markup: true,
      }),
      Widget.Label({
        className: "time",
        hpack: "end",
        hexpand: true,
        label: getTimePassed(n.time),
      }),
    ],
  });

  const body = Widget.Label({
    className: "body",
    hexpand: true,
    use_markup: true,
    maxWidthChars: 50,
    wrap_mode: Pango.WrapMode.WORD_CHAR,
    xalign: 0,
    justification: "left",
    label: n.body.trim(),
    wrap: true,
  });

  const actions = Widget.Box({
    className: "actions",
    children: n.actions.map(({ id, label }) =>
      Widget.Button({
        className: "action_button",
        onClicked: () => {
          n.invoke(id);
          n.dismiss();
        },
        hexpand: true,
        child: Widget.Label(label),
      }),
    ),
  });

  return Widget.EventBox(
    {
      attribute: { id: n.id },
      on_primary_click: n.dismiss,
    },
    Widget.Box(
      {
        className: `notification ${n.urgency}`,
        vertical: true,
      },
      Widget.Box([icon, Widget.Box({ vertical: true }, title, body)]),
      actions,
    ),
  );
}

export function NotificationPopups(monitor = 0) {
  const list = Widget.Box({
    className: "notifications",
    // dunno why but this needs to be here otherwise no popups are shown
    css: "min-width: 2px; min-height: 2px;",
    vertical: true,
    children: notifications.popups.map(Notification),
  });

  function onNotified(_, /** @type {number} */ id) {
    const n = notifications.getNotification(id);
    if (n) list.children = [Notification(n), ...list.children];
  }

  function onDismissed(_, /** @type {number} */ id) {
    list.children.find((n) => n.attribute.id === id)?.destroy();
  }

  list
    .hook(notifications, onNotified, "notified")
    .hook(notifications, onDismissed, "dismissed");

  return Widget.Window({
    monitor,
    name: `notifications${monitor}`,
    className: "notification_popups",
    anchor: ["right"],
    layer: "overlay",
    child: list,
  });
}

export function NotificationsList(monitor = 0) {
  const list = Widget.Box({
    vertical: true,
    vpack: "center",
    className: "notifications",
    children: notifications
      .bind("notifications")
      .as((n) =>
        n.filter((v) => !v.transient).map((n) => Notification(n, true)),
      ),
  });

  function onNotified(_, /** @type {number} */ id) {
    const n = notifications.getNotification(id);
    if (n) list.children = [Notification(n), ...list.children];
  }

  function onDismissed(_, /** @type {number} */ id) {
    list.children.find((n) => n?.attribute?.id === id)?.destroy();
  }

  list
    .hook(notifications, onNotified, "notified")
    .hook(notifications, onDismissed, "dismissed");

  const NoNotifs = Widget.Box({
    className: `notification none`,
    vertical: true,
    vpack: "center",
    children: [Widget.Label("(╯_╰)")], // (╯︵╰,)
  });

  return Widget.Window({
    monitor,
    name: `notifications-list-${monitor}`,
    layer: "overlay",
    visible: false,
    className: "notifications_list",
    anchor: ["right"],
    child: Widget.Scrollable({
      vscroll: "automatic",
      hscroll: "never",
      className: "notifications_container",
      child: list,
      // child: notifications.bind("notifications").as((n) => {
      //   if (n.filter((n) => !n.transient).length > 0) {
      //     return list;
      //   } else return NoNotifs;
      // }),
    }),
  }).hook(
    // close notifications list window when all notifications are cleared
    notifications,
    (self, _) => {
      if (notifications.notifications.length === 0) {
        self.visible = false;
      }
    },
    "closed",
  );
}
