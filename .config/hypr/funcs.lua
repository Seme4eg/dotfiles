function message(var)
  hl.notification.create({ text = "fs=" .. tostring(var), timeout = 2000 })
end

function yt_chapter(dir)
  local key = (dir == "prev") and "left" or "right"
  for _, w in pairs(hl.get_windows()) do
    if w.title and string.find(w.title, " - YouTube - ", 1, true) then
      hl.dispatch(hl.dsp.send_shortcut({
        mods   = "control",
        key    = key,
        window = "address:" .. w.address,
      }))
      return
    end
  end
end

function layout_bind(bind_table)
  return function()
    local workspace = hl.get_active_special_workspace() or
        hl.get_active_workspace()

    if not workspace then return; end

    local layout = workspace.tiled_layout
    if bind_table[layout] then
      hl.dispatch(bind_table[layout])
    end
  end
end

function cycle_window(direction) -- "prev" | "next"
  local ws = hl.get_active_workspace()
  if ws == nil then return end

  -- has_floating: any floating, non-pinned window on THIS workspace
  local has_floating = false
  for _, w in pairs(hl.get_windows()) do
    if w.workspace and w.workspace.id == ws.id
        and w.floating == true and w.pinned == false then
      has_floating = true
      break
    end
  end

  if has_floating then
    hl.dispatch(hl.dsp.window.cycle_next(direction)) -- (?) see note 2
    return
  end

  local layout = ws.tiled_layout

  local msg = {
    monocle = "cycle",
    master  = "roll",
  }
  if msg[layout] then
    hl.dispatch(hl.dsp.layout(msg[layout] .. direction))
  elseif layout == "scrolling" then
    local dir_opt = hl.get_config("scrolling.direction") -- (?) see note 4
    local d
    if direction == "prev" then
      d = (dir_opt == "down") and "up" or "left"
    else
      d = (dir_opt == "down") and "down" or "right"
    end
    hl.dispatch(hl.dsp.layout("focus " .. d))
  else
    -- dwindle / default: plain focus cycle
    hl.dispatch(hl.dsp.window.cycle_next(direction))
  end
end

-------------------------------------------------------------------------------
--                          LID & monitors handling                          --
-------------------------------------------------------------------------------

laptop_mon = "eDP-1"
local lid_ignore = os.getenv("XDG_RUNTIME_DIR") .. "/lidignore"
edp_off_flag = os.getenv("XDG_RUNTIME_DIR") .. "/edp-disabled"

function file_exists(p)
  local f = io.open(p, "r"); if f then
    f:close(); return true
  end; return false
end

local function last_mon()
  local mons = hl.get_monitors()
  return #mons == 1
end

-- laptop panel is the only active monitor? (disabled ones drop from get_monitors)
local function only_laptop_active()
  return last_mon() and mons[1].name == laptop_mon
end

function set_laptop(enabled)
  if not enabled then
    if last_mon() then
      hl.exec_cmd("say -e 'Last screen'")
      return
    end
  end

  hl.monitor({ output = laptop_mon, disabled = not enabled })
  if enabled then
    os.remove(edp_off_flag)
  else
    local f = io.open(edp_off_flag, "w"); if f then f:close() end
  end
end

function lid_close()
  if only_laptop_active() and not file_exists(lid_ignore) then
    hl.exec_cmd("systemctl suspend")
  end
  -- external present -> stay awake, do nothing.
  -- window-move to external handled by monitor.added hook, not here.
end

function lid_open()
  if not only_laptop_active() then
    set_laptop(true)
  end
  if file_exists(lid_ignore) then os.remove(lid_ignore) end
end
