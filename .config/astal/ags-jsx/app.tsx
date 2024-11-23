import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable } from "astal"

import Center from "./js/center.tsx";

import style from "./style.scss"

let theme = Variable("dark");
globalThis.theme = theme;

function Bar(gdkmonitor: Gdk.Monitor) {
  return <window
    className={"bar-" + gdkmonitor}
    gdkmonitor={gdkmonitor}
    exclusivity={Astal.Exclusivity.EXCLUSIVE}
    anchor={Astal.WindowAnchor.TOP
      | Astal.WindowAnchor.LEFT
      | Astal.WindowAnchor.RIGHT}>
    {/* application={App}> // XXX */}
    <centerbox
      className={theme(t => `container_main ${t}`)} >
      <box />
      <box />
      <box />
    </centerbox>
  </window>
}

App.start({
  css: style,
  main() {
    App.get_monitors().map(Bar)
  },
})
