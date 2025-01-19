local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local Mpris = require("lgi").require("AstalMpris")
local Hyprland = require("lgi").require("AstalHyprland")
local Pango = require("lgi").require("Pango")
-- local Variable = astal.Variable

local bind = astal.bind
local map = require("lib").map

local hypr = Hyprland.get_default()

local function Workspaces()
  return Widget.Box({
    class_name = "workspaces",
    spacing = 10,
    bind(hypr, "workspaces"):as(function(wss)
      table.sort(wss, function(a, b)
        return a.id < b.id
      end)

      return map(wss, function(ws)
        return Widget.Label({
          class_name = bind(hypr, "focused-workspace"):as(function(fw)
            return fw == ws and "active" or ""
          end),
          label = bind(hypr, "focused-workspace"):as(function(fw)
            return fw == ws and "X" or "O"
          end),
        })
      end)
    end),
  })
end

local function ClientTitle()
  local focused = bind(hypr, "focused-client")

  return focused:as(function(client)
    return Widget.Label({
      class_name = "client",
      max_width_chars = 25,
      ellipsize = Pango.EllipsizeMode.END,
      -- truncate = true, -- TODO: why its undefined?
      label = bind(client, "title"):as(tostring),
    })
  end)
end

-- local function Media()
-- 	return Widget.Box({
--       class_name: ""
--   })
-- end

-- local function Media()
--   local mpris = Mpris.get_default()
--   local players = bind(mpris, "players")
--   -- print(#players)

--   local player = Variable(players[1])
--   local visible = bind(mpris, "players"):as(function(ps) return #ps > 0 end)

-- for _, p in ipairs(players) do
--   -- 0 - playing; 1 - paused; 2 - stopped (https://aylur.github.io/libastal/mpris/enum.PlaybackStatus.html)
--   print(p.playback_status)
--   if p.playback_status == 0 then
--     player = Variable(p)
--     break
--   end
-- end

-- print(player.title)

-- if not active then
--     for _, player in ipairs(players) do
--         if player.play_back_status == "Paused" then
--             active = player
--             break
--         end
--     end
-- end

-- return Widget.Box()
-- return Widget.Box({
--   class_name = #players == 0 and "media_hidden" or "",
--   spacing = 0,
--   visible,
--   valign = "CENTER",
--   Widget.Box(),
--   Widget.Revealer({
--     reveal_child = visible,
--     -- transition = "crossface",
--     Widget.Box({
--       spacing = 10,
--       Widget.Label({
--         class_name = "icon",
--         visible,
--         label = bind(player, "playback_status"):as(function(s)
--           return s == 0 and "" or ""
--         end),
--       }),
--       Widget.Label({
--         class_name = "title",
--         visible,
--         max_width_chars = 20,
--         -- truncate = true,
--         label = bind(player, "title"):as(tostring)
--       })
--     })
--   }),
-- })
-- end

local function Media()
  local mpris = Mpris.get_default()
  return Widget.Box({
    bind(mpris, "players"):as(function(players)
      local player = players[1]
      if player then
        return Widget.Box({
          Widget.Label({ label = bind(player, "title") }),
        })
      end
    end),
  })
end

return function()
  return Widget.Box({
    spacing = 8,
    Workspaces(),
    ClientTitle(),
    -- Media(),
  })
end
