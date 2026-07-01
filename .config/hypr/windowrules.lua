-- See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

-- EXAMPLE of matching:
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

hl.window_rule({
  match = {
    class = ".*",
  },
  suppress_event = "maximize",
})

-- Just dash of opacity by default
hl.window_rule({
  name = "global_rules",
  match = {
    class = ".*",
  },
  opacity = "0.88 0.8",
})

-- Fix some dragging issues with XWayland. NOTE: breaks games
-- hl.window_rule({
--     -- Fix some dragging issues with XWayland
--     name  = "fix-xwayland-drags",
--     match = {
--         class      = "^$",
--         title      = "^$",
--         xwayland   = true,
--         float      = true,
--         fullscreen = false,
--         pin        = false,
--     },

--     no_focus = true,
-- })

-- --- Terminals ---
-- Define terminal tag to style them uniformly
hl.window_rule({
  match = {
    class = "Alacritty|foot|kitty|com.mitchellh.ghostty",
  },
  tag = "+terminal",
})

hl.window_rule({
  match = {
    tag = "terminal",
  },
  size = "(monitor_w*0.55) (monitor_h*0.5)",
  scroll_touchpad = 1.5,
})

-- --- Opacity ---

-- Dynamic opacity for certain tabs in brave browser
hl.window_rule({
  match = {
    title = ".*(YouTube|Zoom|Daily) - Brave Origin$",
  },
  opacity = "1 1",
})

-- No transparency on media windows
hl.window_rule({
  match = {
    class =
    "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$",
  },
  opacity = "1 1",
})

hl.window_rule({
  name = "pinned_windows",
  match = {
    pin = 1,
  },
  border_size = 1,
  no_initial_focus = true,
  no_follow_mouse = true,
  max_size = "560 320",
})

hl.window_rule({
  name = "picture-in-picture",
  match = {
    title = "(Picture.?in.?[Pp]icture)",
  },
  size = "(monitor_w*0.27) (monitor_h*0.23)",
  move = "(monitor_w-(monitor_w*0.27)) (0)",
  opacity = "1 1",
  float = true,
  pin = true,
  keep_aspect_ratio = true,
  border_size = 0,
  -- yes.. you need to suppress ALL those events in order for popup windows to
  -- not 'unmaximise' your fullscreen clients..
  suppress_event = "fullscreen maximize activatefocus",
  no_initial_focus = true,
})

-- --- Floating windows ---

hl.window_rule({
  match = {
    class = "(xdg-desktop-portal-gtk|DesktopEditors)",
  },
  tag = "+floating-window",
})

hl.window_rule({
  match = {
    class = "(TUI.float|com.gabm.satty)",
  },
  tag = "+floating-window",
})

hl.window_rule({
  match = {
    title =
    "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)",
  },
  tag = "+floating-window",
})

hl.window_rule({
  name = "floating_windows",
  match = {
    tag = "floating-window",
  },
  float = true,
  center = true,
  -- size = (940) (540)
  size = "(monitor_w*0.55) (monitor_h*0.5)",
  border_size = 1,
  -- active/inactvie border color respectively
  -- border_color = "$foreground $color5",
})

-- --- Gaming Stuff ---

hl.window_rule({
  match = {
    class = "Element",
  },
  workspace = "2 silent",
})

hl.window_rule({
  match = {
    class = "org.kde.easyeffects",
  },
  workspace = "5 silent",
})

hl.window_rule({
  match = {
    class = "heroic",
  },
  workspace = "3 silent",
})

-- don't mess me my gaming
hl.window_rule({
  match = {
    class = "(Pinentry-gtk|gcr-prompter)",
  },
  workspace = "1 silent",
})

-- --- Steam ---
hl.window_rule({
  name = "steam",
  match = {
    class = "(s|S)team",
  },
  workspace = "3 silent",
  opacity = "1 1",
  no_blur = true,
})

hl.window_rule({
  match = {
    class = "steam",
    title = "Friends List",
  },
  size = "460 800",
  float = true,
})

-- games (applies to Steam, Heroic & Godot games)
hl.window_rule({
  match = {
    class = "(steam_app.*)",
  },
  tag = "+game",
})

hl.window_rule({
  match = {
    initial_class = "(Godot)",
  },
  tag = "+game",
})

hl.window_rule({
  name = "games",
  match = {
    tag = "game",
  },
  workspace = "3 silent",
  no_blur = true,
  opacity = "1 1",
  fullscreen = true,
  no_anim = true,
  rounding = 0,
  -- render_unfocused_fps hypr config var - 15fps default
  render_unfocused = true,
  confine_pointer = true,
})

-- --- layer rules ---

hl.layer_rule({
  name = "layerrules_rofi",
  match = { namespace = "rofi", },
  blur = true,
  ignore_alpha = 0.5,
  dim_around = true,
  xray = true,
  animation = "popin 85%",
})

-- layerrule = ignore_zero 1, match:namespace rofi
