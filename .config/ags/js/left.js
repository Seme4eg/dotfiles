const hyprland = await Service.import("hyprland");
const mpris = await Service.import("mpris");

function Workspaces() {
  const activeId = hyprland.active.workspace.bind("id");
  const workspaces = hyprland.bind("workspaces").as((ws) =>
    ws.map(({ id }) =>
      Widget.Label({
        // yalign: 0.5,
        className: activeId.as((i) => `${i === id ? "active" : ""}`),
        label: activeId.as((i) => `${i === id ? "X" : "O"}`),
      }),
    ),
  );

  return Widget.Box({
    className: "workspaces",
    children: workspaces,
    spacing: 10,
  });
}

function ClientTitle() {
  return Widget.Label({
    className: "client",
    maxWidthChars: 25,
    ellipsize: true,
    truncate: "end",
    label: hyprland.active.client.bind("title").as((name) => name || "(-_-)"),
  });
}

function Media() {
  const label = Utils.watch(null, mpris, "player-changed", () => {
    if (mpris.players[0]) {
      const { track_artists, track_title } = mpris.players[0];
      return `${track_title} - ${track_artists.join(", ")}`;
    }
  });

  const icon = Utils.watch("", mpris, "player-changed", () => {
    if (mpris.players[0]) {
      return mpris.players[0].play_back_status == "Playing" ? "" : "";
    }
  });

  const className = mpris
    .bind("players")
    .as((p) => "media " + (p.length === 0 ? "media_hidden" : ""));

  // FIXME: doesn't disappear when nothing playing
  return Widget.Box({
    className,
    spacing: 0,
    visible: false,
    children: [
      Widget.Box(),
      Widget.Revealer({
        revealChild: !!label || false,
        transition: "slide_right",
        transitionDuration: 500,
        child: Widget.Box({
          spacing: 10,
          children: [
            Widget.Label({
              className: "icon",
              label: icon || "",
            }),
            Widget.Label({
              label: label || "",
              maxWidthChars: 20,
              ellipsize: true,
              truncate: "end",
            }),
          ],
        }),
      }),
    ],
  });
}

// layout of the bar
export default function Left() {
  return Widget.Box({
    spacing: 8,
    children: [Workspaces(), ClientTitle(), Media()],
  });
}
