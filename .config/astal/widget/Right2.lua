local Widget = require("astal.gtk3.widget")
local Network = require("lgi").require("AstalNetwork")
local bind = require("astal").bind
local GLib = require("lgi").require("GLib", "2.0")
local Variable = require("astal").Variable

local astal = require("astal.gtk3")
local astalify = astal.astalify
local Gtk = astal.Gtk
local ProgressBar = astalify(Gtk.ProgressBar)

local network = Network.get_default()

-- local function IfVPN()
--   return Widget.Revealer({
--     transition_duration = 350,
--     transition_type = "SLIDE_RIGHT",
--     reveal_child = bind(network, "connectivity"):as(function(status)
--       return status == "NONE" or status == "PORTAL"
--     end),
--     Widget.Label({
--       class_name = "disconnected",
--       label = bind(network, "connectivity"):as(function(status)
--         return status == "PORTAL" and "󰤩" or "󰤮"
--       end)
--     })
--   })
-- end

local function IfDisconnected()
  return Widget.Revealer({
    transition_duration = 350,
    transition_type = "SLIDE_RIGHT",
    reveal_child = bind(network, "connectivity"):as(function(status)
      return status == "NONE" or status == "PORTAL"
    end),
    Widget.Label({
      class_name = "disconnected",
      label = bind(network, "connectivity"):as(function(status)
        return status == "PORTAL" and "󰤩" or "󰤮"
      end)
    })
  })
end

local function IfConnected()
  local isConnected = bind(network, "connectivity"):as(
    function(status)
      return status == "LIMITED" or status == "FULL"
    end
  )

  -- XXX: there is a problem here - the bandwidth script uses single file to
  -- measure traffic and if there are 2 processes running and using same file
  -- the whole thing is messed up and it all cuz astal makes it complicated to
  -- work with Variable tables.

  -- local bandwidth = Variable({ up = 0, up_bold = false, down = 0, down_bold = 0 }):poll(
  --   1000,
  --   "bash -c $HOME/.config/ags/scripts/bandwidth",
  --   function(out)
  --     local up_bold = false;
  --     local down_bold = false;

  --     local down, up = out:match("(%S+)%s+(%S+)")

  --     down = tonumber(down)
  --     up = tonumber(up)

  --     if down > 1024 then
  --       down_bold = true
  --       down = down / 1024
  --     end
  --     if up > 1024 then
  --       up_bold = true
  --       up = up / 1024
  --     end

  --     down = math.floor(down)
  --     up = math.floor(up)

  --     print(up, down, up_bold, down_bold)
  --     local t = { up, down, up_bold, down_bold }
  --     return up, down, up_bold, down_bold
  --   end
  -- )


  local up = Variable(0):poll(
    1000,
    "bash -c $HOME/.config/ags/scripts/bandwidth",
    function(out)
      local up = out:match("%S+%s+(%S+)")
      up = tonumber(up)
      return math.floor(up)
    end
  )

  local down = Variable(0):poll(
    1000,
    "bash -c $HOME/.config/ags/scripts/bandwidth",
    function(out)
      local down = out:match("(%S+)%s+%S+")
      down = tonumber(down)
      return math.floor(down)
    end
  )

  return Widget.Revealer({
    class_name = "connected",
    reveal_child = isConnected,
    transition_duration = 350,
    Widget.Overlay({
      child = ProgressBar({
        width_request = bind(network, "connectivity"):as(function(status)
          return status == "LIMITED" or status == "FULL" and 38 or 0
        end),
        valign = "CENTER",
        fraction = bind(network, "wifi"):as(function(v) return v.strength / 100 end)
      }),
      overlays = {
        Widget.Label({
          class_name = bind(up):as(function(v)
            return "up " .. (v > 1024 and "bold" or "")
          end),
          label = bind(up):as(function(v)
            return " " .. (v > 1024 and math.floor(v / 1024) or v)
          end)
        }),
        Widget.Label({
          class_name = bind(down):as(function(v)
            return "down " .. (v > 1024 and "bold" or "")
          end),
          label = bind(down):as(function(v)
            return " " .. (v > 1024 and math.floor(v / 1024) or v)
          end)
        })
      }
    })
  })
end

local function Net()
  return Widget.Box({
    class_name = "network",
    IfDisconnected(),
    IfConnected()
  })
end

local function AudioBlock()
  return Widget.Box({
    class_name = "audio",
    spacing = 7,
    Sink(),
  })
end



local function Backlight()
  local scripts_dir = GLib.getenv("HOME") .. "/.config/astal/scripts"
  local brightness = Variable("0"):watch(
    "bash -c " .. scripts_dir .. "/backlight",
    function(out) return out / 100 end
  )

  return Widget.Overlay({
    class_name = "backlight",
    child = Widget.CircularProgress({ value = bind(brightness) }),
    overlays = {
      Widget.Label({ class_name = "circle_text", label = "󰃝" })
    }
  })
end

return function()
  return Widget.Box({
    class_name = "sys_info",
    spacing = 10,
    Net(),
    Backlight()
  })
end
