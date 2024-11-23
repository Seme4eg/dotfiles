local astal = require("astal")
local Widget = require("astal.gtk3.widget")
-- local Hyprland = astal.require("AstalHyprland")
local Hyprland = require("lgi").require("AstalHyprland")

local bind = astal.bind
local map = require("lib").map

-- local function FocusedClient()
--   local hypr = Hyprland.get_default()
--   local focused = bind(hypr, "focused-client")

--   return Widget.Box({
--     class_name = "Focused",
--     visible = focused,
--     focused:as(function(client)
--       return client and Widget.Label({
--         label = bind(client, "title"):as(tostring),
--       })
--     end),
--   })
-- end

local function Workspaces()
  local hypr = Hyprland.get_default()

  return Widget.Box({
    class_name = "workspaces",
    bind(hypr, "workspaces"):as(function(workspaces)
      table.sort(workspaces, function(a, b)
        return a.id < b.id
      end)

      return map(workspaces, function(id)
        return Widget.Label({
          class_name = bind(hypr, "focused-workspace"):as(function(activeId)
            return activeId == id and "active" or ""
          end),
          label = bind(hypr, "focused-workspace"):as(function(fw)
            return fw == id and "X" or "O"
          end),
          -- label = bind(ws, "id"):as(function(v)
          --   return type(v) == "number" and string.format("%.0f", v) or v
          -- end),
        })
      end)
    end),
  })
end

return function()
  Widget.Box({
    spacing = 8,
    Workspaces()
  })
end
