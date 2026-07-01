mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("footclient"))
hl.bind(mainMod .. " + CTRL + Return", hl.dsp.exec_cmd("[float] foot"))

hl.bind(
  mainMod .. " + SHIFT + M",
  hl.dsp.exec_cmd([[
[float;size (740) (400);move (monitor_w-window_w-40) (-70)]
qutebrowser -R --qt-wrapper PyQt6 -s input.mode_override insert https://monkeytype.com
sleep 2;
hyprctl dispatch 'hl.dsp.focus({window = "class:org.qutebrowser.qutebrowser"})'
]]))
-- bind = SUPERSHIFT, V, exec, [workspace 2; fullscreen] say -e "Starting $(wl-paste) in mpv..."; mpv "$(wl-paste)" || say -e 'Not valid url?'
hl.bind(mainMod .. " + SHIFT + V",
  hl.dsp.exec_cmd("[workspace 5 silent] pkill vnc_start || xdg-terminal-exec vnc_start"))

-- script to prevent accidentially closing games trying to switch to workspace 1
hl.bind(mainMod .. " + Q", function()
  local w = hl.get_active_window()
  if w == nil then return end  -- nothing focused
  if w.fullscreen == 2 then
    hl.exec_cmd("say -e Nope") -- refuse: fullscreen mode 2
  else
    hl.dispatch(hl.dsp.window.close())
  end
end)
hl.bind(mainMod .. " + ALT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + CTRL + Q", hl.dsp.exit(), { locked = true })

hl.bind(
  mainMod .. " + SHIFT + CTRL + U", hl.dsp.exec_cmd("pkill -USR1 hyprlock"),
  { locked = true }
)
hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("systemctl suspend"), { locked = true })

-- --- Lid events ---

-- (all switches listed in `hyrpctl devices`)
hl.bind("switch:on:Lid Switch", lid_close, { locked = true })
hl.bind("switch:off:Lid Switch", lid_open, { locked = true })

-- --- Utility apps/scripts ---

hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("systemctl --user restart ags"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("agsv1 --toggle-window statusbar"))
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.exec_cmd("hyprlock"))
-- create a file to ignore lid-close event once, needed when plugging back to hub
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("touch ~/.cache/lidignore"), { locked = true })
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("record"))
-- minus - code 20, plus - code 21
hl.bind(mainMod .. " + SHIFT + CTRL + code:20", function() set_laptop(false) end)
hl.bind(mainMod .. " + SHIFT + CTRL + code:21", function() set_laptop(true) end)

-- --- Laptop media / brightness keys for volume and LCD brightness ---

-- Audio ---
hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind(
  "CTRL + XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+"),
  { locked = true, repeating = true }
)
hl.bind(
  "CTRL + XF86AudioLowerVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-"),
  { locked = true, repeating = true }
)
hl.bind("CTRL + XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind(mainMod .. " + CTRL + A", hl.dsp.exec_cmd("toggleoutput"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("togglemute"), { locked = true })
-- Brightness ---
hl.bind(
  "XF86MonBrightnessDown",
  hl.dsp.exec_cmd("brightnessctl --min-value=2 -e -s -c backlight set 5%-"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86MonBrightnessUp",
  hl.dsp.exec_cmd("brightnessctl --min-value=2 -e -s -c backlight set 5%+"),
  { locked = true, repeating = true }
)
-- Touchpad ---
--   restart touchpad
-- bindel = ,XF86TouchpadToggle, exec, sudo modprobe -r i2c-hid-acpi && sudo modprobe i2c-hid-acpi

-- --- Playerctl ---

hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind(mainMod .. " + SHIFT + CTRL + P", hl.dsp.exec_cmd("playerctl stop"))
hl.bind(mainMod .. " + bracketleft", hl.dsp.exec_cmd("playerctl previous"))
hl.bind(mainMod .. " + bracketright", hl.dsp.exec_cmd("playerctl next"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("playerctl position 10+"), { repeating = true })
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("playerctl position 10-"), { repeating = true })
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.exec_cmd("playerctl position 1+"), { repeating = true })
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.exec_cmd("playerctl position 1-"), { repeating = true })
hl.bind(mainMod .. " + SHIFT + bracketleft", function() yt_chapter("prev") end)
hl.bind(mainMod .. " + SHIFT + bracketright", yt_chapter)
hl.bind(mainMod .. " + 7", function() yt_chapter("prev") end)
hl.bind(mainMod .. " + 8", yt_chapter)

-- --- Windows / layout binds ---

hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.pin())
hl.bind(
  mainMod .. " + C",
  hl.dsp.window.center() --[[ legacy `1` arg (respect-reserved) has no typed equivalent in 0.55 ]]
)
hl.bind(mainMod .. " + ALT + P", hl.dsp.window.pin())

-- option 2 is like fullscreen, but leaves intact contents of window
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
-- bind = SUPER + CTRL, F, workspaceopt, allfloat
hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

hl.bind(mainMod .. " + T", hl.dsp.window.set_prop({ prop = "opaque", value = "toggle", window = "active" }))

-- --- layout commands ---

hl.bind(mainMod .. " + J", function() cycle_window("next") end)
hl.bind(mainMod .. " + K", function() cycle_window("prev") end)

-- master related:
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.layout("swapwithmaster auto"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.layout("orientationnext"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.layout("orientationprev"))

-- scrolling related:
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. " + SHIFT + CTRL + J", hl.dsp.layout("fit all"))
hl.bind(mainMod .. " + SHIFT + CTRL + K", hl.dsp.layout("colresize all 0.5"))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.layout("fit visible"))
-- Fix for focused window sliding away when colresizing all columns
hl.bind(mainMod .. " + SHIFT + CTRL + K", hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. " + SHIFT + CTRL + K", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("hyprctl keyword -r scrolling:direction down"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprctl keyword -r scrolling:direction right"))

-- --- H J K L for tiled & float windows ---

hl.bind(mainMod .. " + ALT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + ALT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.move({ direction = "r" }))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + CTRL + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.focus({ direction = "right" }))

for i = 1, 5 do
  -- local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + CTRL + " .. i, hl.dsp.window.move({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end

hl.bind(mainMod .. " + SHIFT + CTRL + 1", function()
  local w = hl.get_active_workspace()
  if not w then return; end
  hl.dispatch(hl.dsp.workspace.move({ workspace = w.id, monitor = -1 }))
end)

hl.bind(mainMod .. " + SHIFT + CTRL + code:49", swap_mons)

hl.bind(mainMod .. " + CTRL + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + ALT + mouse:272", hl.dsp.window.resize())

require("submaps")
