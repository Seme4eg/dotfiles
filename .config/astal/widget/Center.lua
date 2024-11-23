local Variable = require("astal").Variable
-- local GLib = require("GLib")
local Widget = require("astal.gtk3.widget")
local json = require("lib.json")

local date = Variable("{}")
    :poll(1000, { "bash", "-c", "date +'{\"count\":\"%j\",\"hour\":\"%H\",\"minute\":\"%M\",\"day\":\"%a %d/%m\"}'" })
-- :poll(1000, { [["date +'{"count":"%j","hour":"%H","minute":"%M","day":"%a %d/%m"}'"]] })

-- local function Clock(format)
-- 	local time = Variable(""):poll(1000, function()
-- 		return GLib.DateTime.new_now_local():format(format)
-- 	end)

-- 	return Widget.Label({
-- 		class_name = "Time",
-- 		on_destroy = function()
-- 			time:drop()
-- 		end,
-- 		label = time(),
-- 	})
-- end

function Clock()
  -- return Widget.Overlay({
  return Widget.Label({
    class_name = "fg",
    css = "color: transparent;",
    label = date(function(str)
      print("DATE" .. date:get())
      local data = json.decode(str)
      return string.format("%s %s", data.count, data.day)
    end)
  })
  -- })
end

return function()
  return Widget.Box({
    class_name = "date",
    Clock()
  })
end
