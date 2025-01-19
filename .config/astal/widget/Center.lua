local Variable = require("astal").Variable
-- local GLib = require("GLib")
local GLib = require("lgi").require("GLib", "2.0")
local Widget = require("astal.gtk3.widget")

-- local date = Variable("{}")
--     :poll(1000, { "bash", "-c", "date +'{\"count\":\"%j\",\"hour\":\"%H\",\"minute\":\"%M\",\"day\":\"%a %d/%m\"}'" })
-- :poll(1000, { [["date +'{"count":"%j","hour":"%H","minute":"%M","day":"%a %d/%m"}'"]] })

-- local function Clock(format)

-- 	return Widget.Label({
-- 		class_name = "Time",
-- 		label = time(),
-- 	})
-- end

function Clock()
  local time = Variable(""):poll(1000, function()
    return GLib.DateTime.new_now_local()
  end)

  local day_format = "#%j %a %d/%m"

  return Widget.Overlay({
    -- FIXME: didn't figure out how to bring child element on top of the overlay
    -- As a hack - duplikating element to get width set and make it transparent.
    child = Widget.Label({
      class_name = "fg",
      css = "color: transparent;",
      on_destroy = function()
        time:drop()
      end,
      label = time(function(date)
        return date:format(day_format)
      end)
    }),
    overlays = {
      Widget.Box({
        halign = "CENTER",
        class_name = "bg",
        Widget.CenterBox({
          Widget.Label({
            class_name = "hour",
            label = time(function(date) return date:format("%H") end)
          }),
          Widget.Label({
            class_name = "colon",
            label = ":"
          }),
          Widget.Label({
            class_name = "minute",
            label = time(function(date) return date:format("%M") end)
          }),
        }),
      }),
      Widget.Label({
        class_name = "fg",
        label = time(function(date) return date:format(day_format) end)
      }),
    }
  })
end

return function()
  return Widget.Box({
    class_name = "date",
    Clock()
  })
end
