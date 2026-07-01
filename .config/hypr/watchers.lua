-- AUTOSTARTUP --
hl.on("hyprland.start", function()
  hl.exec_cmd(
    "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP")
  hl.exec_cmd("systemctl --user start hyprland-session.target")
  -- /usr/libexec/xdg-desktop-portal-hyprland & # ain't needed with soystemd
  -- fix for logitech bolt receiver waking up system immediately after suspend, see arch wiki
  hl.exec_cmd("solaar -w hide")
  hl.exec_cmd("change-theme")
  -- force update everything on every hyprland launch
  hl.exec_cmd("sync_tz_and_loc -f")
  hl.exec_cmd("wl-paste --watch cliphist store")
  -- preserve the data in the clipboard after the application is closed
  hl.exec_cmd("doom env")
  hl.exec_cmd("foot --server")
  hl.exec_cmd("sleep 10; mbsync mailru")
  hl.exec_cmd("brightnessctl -r")
  hl.exec_cmd("hyprpaper")
  -- hot reload any changes in ags bar
  hl.exec_cmd("find ~/.config/ags -type f -name \"*.js\" | entr -p -s \"systemctl --user restart ags\"")
  hl.exec_cmd("$DOTFILES_PATH/install/first-run/all.sh")

  -- startup applications
  hl.exec_cmd("gtk-launch brave-origin.desktop", { workspace = "1 silent" })
  hl.exec_cmd("gtk-launch io.element.Element.desktop", { workspace = "2 silent" })

  -- Slow app launch fix -- set systemd vars
  hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)")
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")

  hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
end)

cur_mon = nil
prev_mon = nil

hl.on("monitor.focused", function(m)
  if m.name ~= cur_mon then
    prev_mon = cur_mon
    cur_mon = m.name
  end
end)

hl.on("monitor.added", function(m)
  -- logic for my home monitor
  if m.description == "Huawei Technologies Co. Inc. XWU-CBA 0x00000001" then
    -- if not lid_shut then return end -- was needed for older setup
    hl.timer(function()
      for _, ws in pairs(hl.get_workspaces()) do
        if ws.monitor and ws.monitor.name == laptop_mon then
          hl.dispatch(hl.dsp.workspace.move({ workspace = ws.id, monitor = m.name }))
        end
      end
      set_laptop(false)
    end, { timeout = 300, type = "oneshot" })
  else
    -- otherwise its some random 2nd monitor and just move 4th and 5th workspace there
    local ws = hl.get_active_workspace()
    hl.dispatch(hl.dsp.workspace.move({ workspace = 4, monitor = m.name }))
    hl.dispatch(hl.dsp.workspace.move({ workspace = 5, monitor = m.name }))
    if ws == nil then return; end
    hl.dispatch(hl.dsp.focus({ workspace = ws.id }))
  end
end)

hl.on("monitor.removed", function(m)
  hl.timer(function()
    if m.name == laptop_mon then
      local w = hl.get_last_window()
      hl.dispatch(hl.dsp.focus({ workspace = w == nil and 1 or w.workspace.id }))
    end
  end, { timeout = 200, type = "oneshot" })
end)

-- reapply disabled-state on every (re)load
local function restore_edp()
  if file_exists(edp_off_flag) then
    hl.monitor({ output = laptop_mon, disabled = true })
  end
end

restore_edp()
hl.on("config.reloaded", restore_edp)
