local App = require("astal.gtk3.app")
local Widget = require("astal.gtk3.widget")
local Anchor = require("astal.gtk3").Astal.WindowAnchor
local Variable = require("astal").Variable

local Center = require("widget.Center")
local Left = require("widget.Left")

local theme = Variable("dark")
-- globalThis.theme = theme; -- XXX

function Bar(monitor)
  return Widget.Window({
    name = "bar-" .. monitor, -- name has to be unique
    monitor = monitor,
    anchor = Anchor.TOP + Anchor.LEFT + Anchor.RIGHT,
    exclusivity = "EXCLUSIVE",
    -- child: Widget.CenterBox({
    Widget.CenterBox({
      -- add 'slim' to make status bar 'slim'
      class_name = theme(function(s) return "container_main" .. s end),
      -- start_widget: Left(),
      -- center_widget: Center(),
      -- end_widget: Right(),
      start_widget = Left(),
      -- center_widget = Center(),
      center_widget = Widget.Box(), --core dumps every fucking where
      --fuck this shit im out, tf pushing such unstable shit to public
      end_widget = Widget.Box()
    }),
  })
end

App:start({
  main = function()
    -- you will instantiate Widgets here
    -- and setup anything else if you need
    Bar(0)
  end,
})
