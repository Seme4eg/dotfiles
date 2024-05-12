const date = Variable("", {
  poll: [
    1000,
    `date +'{"count":"%j","hour":"%H","minute":"%M","day":"%a %d/%m"}'`,
  ],
});

function Clock() {
  return Widget.Overlay({
    // FIXME: didn't figure out how to bring child element on top of the overlay
    // As a hack - duplikating element to get width set and make it transparent.
    child: Widget.Label({
      className: "fg",
      css: "color: transparent;",
      label: date
        .bind()
        .as((str) => `#${JSON.parse(str).count} ${JSON.parse(str).day}`),
    }),
    overlays: [
      Widget.Box({
        hpack: "center",
        className: "bg",
        children: [
          Widget.CenterBox({
            startWidget: Widget.Label({
              className: "hour",
              label: date.bind().as((str) => JSON.parse(str).hour),
            }),
            centerWidget: Widget.Label({
              className: "colon",
              label: ":",
            }),
            endWidget: Widget.Label({
              className: "minute",
              label: date.bind().as((str) => JSON.parse(str).minute),
            }),
          }),
        ],
      }),
      Widget.Label({
        className: "fg",
        label: date
          .bind()
          .as((str) => `#${JSON.parse(str).count} ${JSON.parse(str).day}`),
      }),
    ],
  });
}

export default function Center() {
  return Widget.Box({
    className: "date",
    children: [Clock()],
  });
}
