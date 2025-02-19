local Widget = require("astal.gtk3.widget")

local Right1 = require("widget.Right1")
local Right2 = require("widget.Right2")
local Right3 = require("widget.Right3")

return function()
  return Widget.Box({
    halign = "END",
    spacing = 8,
    class_name = "right_container",
    Right1(),
    Right2(),
    Right3()
  })
end
