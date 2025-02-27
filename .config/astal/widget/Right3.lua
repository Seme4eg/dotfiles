local astal = require("astal.gtk3")
local Widget = require("astal.gtk3.widget")
local Battery = require("lgi").require("AstalBattery")
local Variable = require("astal").Variable
local bind = require("astal").bind
local json = require("../lib/json")
local map = require("lib").map

local astalify = astal.astalify
local Gtk = astal.Gtk
local Separator = astalify(Gtk.Separator)

local function CpuWidget()
  local hist_len = 17

  local init_arr = {}
  for i = 1, hist_len do
    init_arr[i] = 0
  end

  local cpu
  cpu = Variable(init_arr):poll(
    2000,
    [[bash -c "top -b -n 1 | grep %Cpu | awk '{print \$2 + \$4 + \$6}'"]],
    function(out)
      -- I think this is due to reference semantics. When you do cpu:get()
      -- within the callback function, it returns the same table that is stored
      -- internally, which you then modify in-place and return. It's the same
      -- value, so the Variable doesn't bother with notifying its users. Try
      -- actually creating a copy of it.
      --             (c) - some good guy on ags discord
      local load = out / 100;
      local temp = cpu:get();
      local copy = {}
      for i = 1, #cpu:get() do
        copy[i] = temp[i]
      end
      table.remove(copy, 1)
      table.insert(copy, load)
      return copy
    end
  )

  local cpu_temp = Variable("40"):poll(
    2000,
    "sensors -j",
    function(out)
      local decoded = json.decode(out)["coretemp-isa-0000"]["Package id 0"].temp1_input
      local temp = tonumber(decoded)
      return math.floor(temp) .. "°"
    end
  )

  return Widget.Box({
    class_name = "cpu",
    vertical = true,
    Widget.Box({
      class_name = "label",
      Widget.Label({ class_name = "text", label = "cpu" }),
      Widget.Label({
        class_name = "value",
        hexpand = true,
        halign = "END",
        label = bind(cpu_temp)
      }),
    }),
    Widget.Box({
      vexpand = true,
      -- bind(cpu)
      bind(cpu):as(function(loads)
        return map(loads, function(load)
          -- print(load)
          return Widget.LevelBar({
            vertical = true,
            inverted = true,
            value = load
          })
        end)
      end)
    })
  })
end

local function Memory()
  local get = function(what, from)
    for line in string.gmatch(from, "[^\n]+") do
      if string.find(line, what .. ":") then
        local result = {}
        for word in string.gmatch(line, "%S+") do
          table.insert(result, word)
        end
        return result
      end
    end
    return nil
  end

  -- Ram value for laptops with less ram to not display 'cached' mem
  -- const ram = Variable(0, {
  --   poll: [
  --     2000,
  --     "free",
  --     (out) => {
  --       // returns total, used, free, shared and cache respectively
  --       let ram = get("Mem", out).splice(1, 5);

  --       // divide (used - cached) by total
  --       return (ram[1] - ram[4]) / ram[0];
  --     },
  --   ],
  -- });

  local ram = Variable(0):poll(2000, "free", function(out)
    local ram = get("Mem", out) -- splice(1, 2) - we only need 'total' and 'used'
    return ram[3] / ram[2]      -- divide used by total, excluding zram
  end)

  return Widget.Overlay({
    class_name = "memory",
    child = Widget.CircularProgress({ value = bind(ram):as(tostring) }),
    overlays = {
      Widget.Label({ class_name = "circle_text", label = "󰍛" }),
    },
  })
end

local function Bat()
  local bat = Battery.get_default()

  local percent_class = Variable.derive(
    { bind(bat, "charging"), bind(bat, "percentage") },
    function(charging, percentage)
      return "percent" .. (charging and " charging" or percentage <= 0.15 and " low" or "")
    end
  )

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
      label = bind(time_remaining),
    })
  end

  -- HACK: cuz for some reason 'bat' doesn't refresh 'energy_rate' value unless
  -- you obtain new 'get_default'
  local rate = Variable(""):poll(1000, function()
    return string.format("%dW", math.floor(bat:get_energy_rate() + 0.5))
  end)

  return Widget.Box({
    visible = bind(bat, "is_present"), -- :as(function(v) return v end)
    class_name = "battery",
    Widget.Box({
      class_name = bind(percent_class),
      spacing = 0,
      Widget.Label({
        label = bind(bat, "percentage"):as(function(v)
          return math.floor(v * 100)
        end),
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
      child = TimeRemaining("color: transparent;"),
      overlays = {
        Widget.Label({
          halign = "START",
          label = bind(rate),
          class_name = "energy_rate",
        }),
        TimeRemaining(),
      },
    }),
  })
end

return function()
  return Widget.Box({
    class_name = "telemetery",
    spacing = 11,
    CpuWidget(),
    Memory(),
    Bat(),
  })
end
