-------------------------------------------------------------------------------
--                               Macro library                               --
-------------------------------------------------------------------------------
-- Every macro/*.lua is loaded automatically and must return:
--   { bind = "SUPER + ALT + X", run = function(m) ... end, window = "title"? }
-- The bind toggles: first press starts run(m), second press stops it.
-- Keys go to the window that was active when the macro started, or with
-- `window` to the first window whose title contains it (stops when it's gone).
-- While any macro runs, focus_on_activate is off so windows don't steal focus.
-- Inside run():
--   m.press(key, mods?)  tap key (mods like "control")
--   m.down(key)          hold key (released automatically on stop)
--   m.up(key)            release key
--   m.sleep(ms)          wait without blocking Hyprland
--   m.exec(cmd)          run shell command

local dir = os.getenv("HOME") .. "/.config/hypr/macro"

local running = {} -- macro name -> state

local function notify(text)
  hl.notification.create({ text = text, timeout = 5000, icon = "error" })
end

local function find(title)
  for _, win in pairs(hl.get_windows()) do
    if win.title and string.find(win.title, title, 1, true) then
      return "address:" .. win.address
    end
  end
end

local function key_state(st, key, state)
  hl.dispatch(hl.dsp.send_key_state({ mods = "", key = key, state = state, window = st.win }))
end

local function stop(name)
  local st = running[name]
  if not st then
    return
  end
  running[name] = nil -- suspended coroutine is never resumed, just collected
  if st.timer then
    st.timer:set_enabled(false)
  end
  for key in pairs(st.held) do
    key_state(st, key, "up") -- never leave keys held down
  end
  if not next(running) then
    hl.config({ misc = { focus_on_activate = true } }) -- after the release: reloads config
  end
end

-- hl.* must never be called inside a coroutine (raises on the main Lua state
-- and freezes Hyprland), so run() only yields commands and step() executes them
local m = {}
for _, cmd in ipairs({ "press", "down", "up", "sleep", "exec" }) do
  m[cmd] = function(...)
    coroutine.yield(cmd, ...)
  end
end

local MAX_WITHOUT_SLEEP = 1000 -- a loop with no m.sleep() would hang Hyprland

local function step(name, st)
  if st.title and not find(st.title) then
    return stop(name)
  end
  for _ = 1, MAX_WITHOUT_SLEEP do
    if running[name] ~= st then
      return -- stopped while sleeping
    end
    local ok, cmd, key, arg = coroutine.resume(st.co)
    if not ok then
      notify("macro " .. name .. ": " .. tostring(cmd))
      return stop(name)
    end
    if coroutine.status(st.co) == "dead" then
      return stop(name)
    end

    if cmd == "sleep" then
      st.timer = hl.timer(function()
        step(name, st)
      end, { timeout = key, type = "oneshot" })
      return
    elseif cmd == "exec" then
      hl.exec_cmd(key)
    elseif cmd == "press" then
      hl.dispatch(hl.dsp.send_shortcut({ mods = arg or "", key = key, window = st.win }))
    else -- "down" / "up"
      st.held[key] = (cmd == "down") or nil
      key_state(st, key, cmd)
    end
  end
  notify("macro " .. name .. ": " .. MAX_WITHOUT_SLEEP .. " keys without m.sleep(), stopped")
  stop(name)
end

local function start(name, spec)
  local win
  if spec.window then
    win = find(spec.window)
    if not win then
      return notify("macro " .. name .. ": no window titled " .. spec.window)
    end
  else
    win = hl.get_active_window()
    win = win and ("address:" .. win.address)
  end
  local st = {
    held = {},
    win = win,
    title = spec.window,
    co = coroutine.create(function()
      spec.run(m)
    end),
  }
  if not next(running) then
    hl.config({ misc = { focus_on_activate = false } }) -- before any dispatch
  end
  running[name] = st
  -- a key sent while the bind's release event is handled gets dropped
  st.timer = hl.timer(function()
    step(name, st)
  end, { timeout = 100, type = "oneshot" })
end

local ls = io.popen("ls -1 " .. dir .. "/*.lua 2>/dev/null")
for path in ls:lines() do
  local name = path:match("([^/]+)%.lua$")
  local ok, spec = pcall(dofile, path)
  if not ok then
    notify("macro " .. name .. ": " .. tostring(spec))
  elseif type(spec) ~= "table" or not spec.bind or not spec.run then
    notify("macro " .. name .. ": must return { bind = ..., run = ... }")
  else
    hl.bind(spec.bind, function()
      if running[name] then
        stop(name)
      else
        start(name, spec)
      end
    end, { release = true }) -- on press, sending keys while bind keys are held re-fires bind and sticks keys
  end
end
ls:close()

-- panic stop: a lone key has no modifiers for injected keys to collide with,
-- and F12 is in no macro's output, so a running macro can't trigger it
hl.bind("F12", function()
  for name in pairs(running) do
    stop(name)
  end
end, { release = true })
