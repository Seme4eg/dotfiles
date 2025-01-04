const hyprland = await Service.import("hyprland");
const mpris = await Service.import("mpris");

function Workspaces() {
  const activeId = hyprland.active.workspace.bind("id");
  const workspaces = hyprland.bind("workspaces").as((ws) =>
    ws
      .sort((a, b) => a.id - b.id)
      .map(({ id }) =>
        Widget.Label({
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
  const trackTitle = Utils.watch(
    null,
    mpris,
    "player-changed",
    () => {
      let active = mpris.players.find(p => p.play_back_status === "Playing") ||
        mpris.players.find(p => p.play_back_status === "Paused")

      return active.track_title
    }
  )

  const artist = Utils.watch(
    null,
    mpris,
    "player-changed",
    () => {
      let active = mpris.players.find(p => p.play_back_status === "Playing") ||
        mpris.players.find(p => p.play_back_status === "Paused")

      return "by " + active.track_artists?.join(", ")
    }
  )
  const icon = Utils.watch(
    null,
    mpris,
    "player-changed",
    () => {
      let active = mpris.players.find(p => p.play_back_status === "Playing") ||
        mpris.players.find(p => p.play_back_status === "Paused")

      return active?.play_back_status == "Playing" ? "" : ""
    }
  )

  const revealArtist = Utils.watch(
    null,
    mpris,
    "player-changed",
    () => {
      let active = mpris.players.find(p => p.play_back_status === "Playing") ||
        mpris.players.find(p => p.play_back_status === "Paused")

      return !!active.track_artists?.length &&
        active.track_artists?.join("").length > 1
    }
  )
  const className = mpris
    .bind("players")
    .as((p) => "media " + (p.length === 0 ? "media_hidden" : ""));

  const visible = mpris.bind("players").as((p) => p.length > 0);

  return Widget.Box({
    className,
    spacing: 0,
    visible,
    children: [
      Widget.Box(),
      Widget.Revealer({
        revealChild: visible,
        transition: "crossfade",
        child: Widget.Box({
          spacing: 10,
          children: [
            Widget.Label({
              className: "icon",
              visible,
              label: icon,
            }),
            Widget.Box({
              vertical: true,
              vpack: "center",
              hpack: "start",
              children: [
                Widget.Label({
                  className: "title",
                  label: trackTitle,
                  visible,
                  maxWidthChars: 20,
                  ellipsize: true,
                  truncate: "end",
                }),
                Widget.Revealer({
                  transition: "slide_down",
                  transitionDuration: 250,
                  revealChild: revealArtist,
                  child: Widget.Label({
                    className: "artist",
                    label: artist,
                    hpack: "start",
                    visible,
                  }),
                }),
              ],
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
