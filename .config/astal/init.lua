local astal = require("astal")
local App = require("astal.gtk3.app")
local GLib = require("lgi").require("GLib", "2.0")
local Widget = require("astal.gtk3.widget")
local Anchor = require("astal.gtk3").Astal.WindowAnchor
local Variable = require("astal").Variable

-- pcall(require, "luarocks.loader") -- XXX

-- local icons = config_dir .. "/icons" XXX

local astal_styles_dir = GLib.getenv("HOME") .. "/.config/astal/styles"
local scss = astal_styles_dir .. "/main.scss"
local css = GLib.getenv("HOME") .. "/.cache/astal/astal.css"
local function reloadCSS()
  astal.exec(string.format("sass --no-source-map %s %s", scss, css))
  App:reset_css()
  App:apply_css(css)
end

-- XXX: ?in case you will need to reload styles manually - run 'agsv1 -r "reloadCSS()"'
-- from terminal, after you uncomment line below.
-- globalThis.reloadCSS = reloadCSS;
astal.monitor_file(GLib.getenv("HOME") .. "/.cache/wal/colors.scss", reloadCSS)
astal.monitor_file(astal_styles_dir, reloadCSS)

-- local Left = require("widget.Left")
local Center = require("widget.Center")
-- local Right = require("widget.Right")

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
      start_widget = Widget.Box(),
      center_widget = Center(),
      end_widget = Widget.Box()
    }),
  })
end

App:start({
  css = css,
  main = function()
    Bar(0)
  end,
})
