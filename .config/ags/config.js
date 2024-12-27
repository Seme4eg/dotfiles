import Left from "./js/left.js";
import Center from "./js/center.js";
import Right from "./js/right.js";

// widgets can be only assigned as a child in one container
// so to make a reuseable widget, make it a function
// then you can simply instantiate one by calling it

// target css file
const css = `${App.configDir}/compiled.css`;

function reloadCSS() {
  const scss = `${App.configDir}/styles/main.scss`;
  Utils.exec(`sass --no-source-map ${scss} ${css}`);
  App.resetCss();
  App.applyCss(css);
}
// in case you will need to reload styles manually - run 'agsv1 -r "reloadCSS()"'
// from terminal, after you uncomment line below.
// globalThis.reloadCSS = reloadCSS;
Utils.monitorFile(`${Utils.HOME}/.cache/wal/colors.scss`, reloadCSS);

Utils.monitorFile(
  // directory that contains the scss files
  `${App.configDir}/styles`,
  reloadCSS
);

let theme = Variable("dark");
globalThis.theme = theme;

function Bar(monitor = 0) {
  return Widget.Window({
    name: `bar-${monitor}`, // name has to be unique
    monitor,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    // layer: "top",
    child: Widget.CenterBox({
      // add 'slim' to make status bar 'slim'
      className: theme.bind().as((s) => `container_main ${s}`),
      start_widget: Left(),
      center_widget: Center(),
      end_widget: Right(),
    }),
  });
}

App.config({
  style: css,
  windows: [
    Bar(), // you can call it, for each monitor: Bar(0), Bar(1)
  ],
});

export {};
