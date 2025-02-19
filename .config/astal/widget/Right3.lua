local astal = require("astal.gtk3")
local Widget = require("astal.gtk3.widget")
local Battery = require("lgi").require("AstalBattery")
local Variable = require("astal").Variable
local bind = require("astal").bind

local astalify = astal.astalify
local Gtk = astal.Gtk
local Separator = astalify(Gtk.Separator)

local function Bat()
  local bat = Battery.get_default()

  local percent_class = Variable.derive(
    { bind(bat, "charging"), bind(bat, "percentage") },
    function(charging, percentage)
      return "percent" ..
          (charging and " charging" or percentage <= 0.15 and " low" or "")
    end)

  -- HACK: cuz for some reason 'bat' doesn't refresh 'energy_rate' value unless
  -- you obtain new 'get_default'
  -- local time_remaining = Variable.derive(
  --   { bind(bat, "time_to_full"), bind(bat, "time_to_empty"), bind(bat, "charging") },
  --   function(to_full, to_empty, is_charging)
  --     local remaining = is_charging and to_full or to_empty
  --     return math.floor(remaining / 60) .. "m"
  --   end
  -- )
  local time_remaining = Variable(""):poll(1000, function()
    local time_to_full = Battery.get_default().time_to_full
    local time_to_empty = Battery.get_default().time_to_empty
    local is_charging = Battery.get_default().charging
    local remaining = is_charging and time_to_full or time_to_empty
    return math.floor(remaining / 60) .. "m"
  end)
  local TimeRemaining = function(css)
    css = css or ""
    return Widget.Label({
      halign = "CENTER",
      css = css,
      class_name = "time_remaining",
      label = bind(time_remaining)
    })
  end

  -- XXX: yes, this feckin shit segfaults still, after one year of astal present..
  -- local updatesCount = Variable("~"):poll(
  --   1000, -- or whatever time
  --   { "bash", "-c", "echo yes" }
  -- )

  -- HACK: cuz for some reason 'bat' doesn't refresh 'energy_rate' value unless
  -- you obtain new 'get_default'
  local rate = Variable(""):poll(1000, function()
    return string.format("%dW", math.floor(bat:get_energy_rate() + 0.5))
  end)

  -- local rate = Variable(bat:get_energy_rate())

  return Widget.Box({
    visible = bind(bat, "is_present"), -- :as(function(v) return v end)
    class_name = "battery",
    Widget.Box({
      class_name = bind(percent_class),
      spacing = 0,
      Widget.Label({
        label = bind(bat, "percentage")
            :as(function(v) return math.floor(v * 100) end)
        -- label = bind(updatesCount)
      }),
      Widget.Label({
        class_name = "icon",
        label = "󱐋",
      }),
    }),
    Separator(),
    -- using overlay here to not extend the height of the bar
    Widget.Overlay({
      class_name = "info",
      child = TimeRemaining(), -- ("color: transparent;")
      overlays = {
        Widget.Label({
          halign = "START",
          label = bind(rate),
          class_name = "energy_rate",
        }),
        TimeRemaining()

        -- bind(time_remaining):as(function(v)
        --   -- css = css or ""
        --   return Widget.Label({
        --     halign = "CENTER",
        --     css = "",
        --     class_name = "time_remaining",
        --     label = bind(v):as(tostring)
        --   })
        -- end)

      }
    })
  })
end

return function()
  return Widget.Box({
    class_name = "telemetery",
    spacing = 11,
    Bat()
  })
end
