-- NOTE: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
--
-- You can also add a d flag if you want the env var to be exported to D-Bus
-- (systemd only):
-- envd = XCURSOR_SIZE,24

-- hl.env("HYPRLAND_TRACE", "1") - Enables more verbose logging.

hl.env("DISPLAY_SCALE", "$display_scale")
hl.env("TERMINAL", "foot")

-- Toolkit Backend Variables
hl.env("GDK_BACKEND", "wayland,x11,*")   -- GTK: Use Wayland if available; if not, try X11 and then any other GDK backend.
hl.env("QT_QPA_PLATFORM", "wayland;xcb") -- Qt: Use Wayland if available, fall back to X11 if not.
hl.env("SDL_VIDEODRIVER", "wayland")     -- Run SDL2 applications on Wayland. Remove or set to x11 if games that provide older versions of SDL cause compatibility issues
hl.env("CLUTTER_BACKEND", "wayland")     -- Clutter package already has Wayland enabled, this variable will force Clutter applications to try and use the Wayland backend

-- XDG specifications fail-save
-- better support for screen sharing (Google Meet, Discord, etc)
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- QT Variables
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")         -- (From the Qt documentation) enables automatic scaling, based on the monitor’s pixel density
hl.env("QT_QPA_PLATFORM", "wayland;xcb")           -- Tell Qt applications to use the Wayland backend, and fall back to X11 if Wayland is unavailable
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1") -- Disables window decorations on Qt applications
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")            -- Tells Qt based applications to pick your theme from qt5ct, use with Kvantum.

-- Theming & Cursor
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("HYPRCURSOR_SIZE", "24")

-- for heroic, brave-origin, etc
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")

-- needed when no soystemd for telega notifications
-- export $(dbus-launch --exit-with-session)
