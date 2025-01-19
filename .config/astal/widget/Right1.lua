local astal = require("astal.gtk3")
local Widget = require("astal.gtk3.widget")
local Tray = require("lgi").require("AstalTray")
local Hyprland = require("lgi").require("AstalHyprland")
local Variable = require("astal").Variable

local bind = require("astal").bind
local map = require("lib").map

local astalify = astal.astalify
local Gtk = astal.Gtk
local Separator = astalify(Gtk.Separator)

local spacing = 13

local tray = Tray.get_default()
local hypr = Hyprland.get_default()

local function SysTray(reveal)
  local TrayItem = function(item)
    return Widget.MenuButton({
      tooltip_markup = bind(item, "tooltip_markup"),
      use_popover = false,
      menu_model = bind(item, "menu-model"),
      action_group = bind(item, "action-group"):as(function(ag)
        return { "dbusmenu", ag }
      end),
      Widget.Icon({
        gicon = bind(item, "gicon"),
      }),
    })
  end

  return Widget.Revealer({
    -- https://docs.gtk.org/gtk3/enum.RevealerTransitionType.html
    transition_type = "SLIDE_LEFT",
    transition_duration = 350,
    reveal_child = reveal,
    Widget.Box({
      spacing = 5,
      class_name = "tray",
      bind(tray, "items"):as(function(items)
        local r = {}
        for _, value in ipairs(items) do
          if value.id ~= nil then
            table.insert(r, value)
          end
        end

        return map(r, function(item) return TrayItem(item) end)
      end),
    })
  })
end

local function Layout()
  -- local DEFAULT_KB <const> = "at-translated-set-2-keyboard"
  return Widget.Label({
    class_name = "layout",
    setup = function(self)
      self:hook(hypr, "keyboard-layout", function(_, _, layout)
        self.label = string.upper(string.sub(tostring(layout), 1, 2))
      end)
    end,
  })
end

local function Submap()
  return Widget.Revealer({
    transition_type = "SLIDE_DOWN",
    transition_duration = 250,
    reveal_child = false,
    setup = function(self)
      self:hook(hypr, "submap", function(_, name, _)
        self.reveal_child = name ~= ""
      end)
    end,
    Widget.Label({
      class_name = "submap",
      setup = function(self)
        self:hook(hypr, "submap", function(_, name, _)
          self.label = name
        end)
      end,
    })
  })
end

local function LayoutAndSubmap()
  return Widget.Box({
    class_name = "network", -- XXX what?
    vertical = true,
    valign = "CENTER",
    Layout(),
    Submap()
  })
end

local function TrayAndLayout()
  local revealTray = bind(tray, "items"):as(function(r) return #r > 0 end)

  return Widget.Box({
    spacing = bind(tray, "items"):as(function(r) return #r > 0 and spacing or 0 end),
    SysTray(revealTray),
    LayoutAndSubmap()
  })
end

local function WeatherAndUpdates()
  -- local updatesCount = Variable("~"):poll(
  --   60 * 60 * 1000, -- once an hour
  --   { "bash", "-c", "checkupdates | wc -l" }
  -- )

  -- local weather = Variable("···"):poll(
  --   60 * 60 * 1000,
  --   { "bash", "-c", "$HOME/.config/ags/scripts/weather" },
  --   function(out, _)
  --     if #out > 8 then
  --       return "󰒏" -- length more than 8 is an error from server
  --     elseif #out > 0 then
  --       return out
  --     end
  --     return "···"
  --   end
  -- )

  local packageIcon = "󰏗 " --   󰏗

  return Widget.Overlay({
    class_name = "weather_and_updates",
    Separator({
      valign = "CENTER",
      width_request = 41
    }),
    overlays = {
      Widget.Box({
        vertical = true,
        halign = "CENTER",
        -- Widget.Label({ label = bind(weather) }),
        -- Widget.Label({
        --   label = bind(updatesCount):as(function(v) return packageIcon .. v end)
        -- })
      })
    }
  })
end

return function()
  return Widget.Box({
    class_name = "user_info",
    spacing = spacing,
    TrayAndLayout(),
    WeatherAndUpdates()
  })
end
