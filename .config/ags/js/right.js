import RLeft from "./right_left.js";
import RCenter from "./right_center.js";
import RRight from "./right_right.js";

export default function Right() {
  return Widget.Box({
    hpack: "end",
    spacing: 8,
    className: "right_container",
    children: [RLeft(), RCenter(), RRight()],
  });
}
