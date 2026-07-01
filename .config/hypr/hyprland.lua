-- NOTE: each require() call is specifically made by Hyprland to be a separate
-- lua “scope”, so errors in one require()d file do not stop execution of other
-- files

require("env")
require("funcs")
require("watchers")

-- error handling for first startup when that file isn't generated yet
local colors, err = loadfile(os.getenv("HOME") .. "/.cache/wal/hyprland-colors.lua")
if colors then
  colors()
else
  hl.notification.create({ text = "load fail: " .. err, timeout = 5000, icon = "error" })
end

local vnc_conf, _ = loadfile(os.getenv("HOME") .. "/.cache/hypr-vnc-state.lua")
if vnc_conf then
  vnc_conf()
end

require("bindings")
require("windowrules")

hl.monitor({
  output = laptop_mon,
  mode = "2880x1920@120.00",
  bitdepth = 10,
  cm = "auto",
  position = "0x0",
  scale = 1.67, -- replace output selector with 13-inch desc: in case of conflicts
})

-- rule for randomly connected monitors
hl.monitor({
  output = "", -- or 1920x1080@60.00Hz
  bitdepth = 10,
  cm = "auto",
  mode = "preferred",
  position = "auto-center-up",
})

-- WORKSPACE RULES
hl.workspace_rule({
  workspace = "r[1-2]",
  monitor = laptop_mon,
})

hl.workspace_rule({
  workspace = "2",
  layout = "scrolling",
})

hl.workspace_rule({
  workspace = "4",
  layout = "master",
})

hl.config({
  general = {
    gaps_in = 2,
    gaps_out = "6",
    border_size = 1,
    col = {
      active_border = { colors = { color5, color6 }, angle = 45 },
      inactive_border = "rgba(00000000)",
      nogroup_border_active = { colors = { color5, color6 }, angle = 45 },
      nogroup_border = "rgba(00000000)",
    },
    layout = "monocle",    -- dwindle / master / scrolling / monocle
    allow_tearing = false, -- DON'T TURN IT ON, breaks games fps
  },
  decoration = {
    rounding = 13,
    rounding_power = 4,
    shadow = {
      enabled = false,
    },
    blur = {
      enabled = true, -- enable dual kavase window background blur
      size = 2,       -- minimum 1
      passes = 2,     -- minimum 1, more passes = more resource intensive.
      xray = true,
    },
    glow = {
      enabled = true,
      range = 10,
      color = color5,
      color_inactive = "rgba(00000000)",
    },
  },

  input = {
    -- --- keyboard ---
    -- https://wiki.hyprland.org/Configuring/Variables/#xkb-settings
    -- man xkeyboard-config
    kb_layout = "us, ru", -- , th
    -- kb_variant = , , pat
    -- kb_layout = us, us, ru
    -- kb_variant = , colemak_dh_iso,
    kb_options = "ctrl:swapcaps, grp:win_space_toggle",
    repeat_rate = 100,
    repeat_delay = 280,
    sensitivity = 1.0,  -- mouse input sensitivity. -1.0 to 1.0.
    accel_profile = "flat",
    focus_on_close = 2, -- focus most recent window
    -- follow_mouse = 1 # <- default
    -- float_switch_override_focus = 2 # NOTE: testing again, default - 1, 0 - disabled
    touchpad = {
      -- disable_while_typing = false, -- uncomment when gaming without mouse
      natural_scroll = true,
      tap_to_click = true,
      drag_lock = 0, -- default now
    },
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    mouse_move_enables_dpms = false,
    focus_on_activate = true,
    key_press_enables_dpms = true,
    animate_manual_resizes = true,
    animate_mouse_windowdragging = true,
    -- don't track initial workspace on which window was opened, 1 - default
    initial_workspace_tracking = 0,
    on_focus_under_fullscreen = 1,
    vrr = 3, -- fullscreen with `video` or `game` content type
    anr_missed_pings = 3,
  },
  binds = {
    workspace_back_and_forth = true,     -- switch to current workspace to switch to previous one
    workspace_center_on = 1,             -- center cursor on last window when switching to workspace
    focus_preferred_method = 1,          -- find focus by longer shared edges
    movefocus_cycles_fullscreen = false, -- <- is default on wiki, but seems that not
  },
  xwayland = {
    use_nearest_neighbor = false,
  },
  render = {
    direct_scanout = 2,
    cm_auto_hdr = 0,
    -- Eclipse apps flickering:
    --  https://github.com/hyprwm/Hyprland/issues/6844#issuecomment-2669164016
  },
  cursor = {
    inactive_timeout = 2,
    hide_on_key_press = true,
    -- NOTE: try setting to 0 if having low gpu usage again
    -- set to 1 for people on stream to see your cursor
    no_hardware_cursors = 2,
    persistent_warps = true,
    warp_on_change_workspace = 1,
    default_monitor = laptop_mon
  },
  dwindle = {
    -- 0 - follow mouse, 1 - split to top left, 2 - split to bottom right
    force_split = 0,
  },
  master = {
    new_status = "master",
    mfact = 0.54, -- default .55
    new_on_top = true,
  },
  scrolling = {
    -- direction = down
    follow_min_visible = 0.1, -- 0.4 - default
  },
  debug = {
    disable_logs = false,
    -- enable_stdout_logs = true
  },
  ecosystem = {
    no_update_news = true,
    no_donation_nag = true,
  },
})

-- ANIMATIONS
hl.curve("smoothIn", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })
hl.animation({
  leaf = "windows",
  enabled = true,
  speed = 2,
  bezier = "default",
  style = "popin 80%",
})
hl.animation({
  leaf = "windowsOut",
  enabled = true,
  speed = 2,
  bezier = "default",
  style = "popin 90%",
})
hl.animation({
  leaf = "windowsMove",
  enabled = true,
  speed = 4,
  bezier = "default",
})
hl.animation({
  leaf = "layers",
  enabled = true,
  speed = 2,
  bezier = "default",
  style = "fade 60%",
})
hl.animation({
  leaf = "border",
  enabled = true,
  speed = 9,
  bezier = "default",
})
hl.animation({
  leaf = "fade",
  enabled = true,
  speed = 4,
  bezier = "smoothIn",
})
hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 2,
  bezier = "default",
  style = "fade",
})
hl.animation({
  leaf = "monitorAdded",
  enabled = true,
  speed = 2,
  bezier = "default",
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})
hl.gesture({
  fingers = 3,
  direction = "vertical",
  action = "fullscreen",
})
