-- Forza AFK: hold W to race, reload the race, CYCLES times
local CYCLES = 10

-- what to send ("down"/"up" = hold/release W), gap in ms before the NEXT step
local steps = {
  { "down",   280000 },
  { "up",     10000 },
  { "down",   270000 },
  { "up",     500 },
  { "escape", 1500 },
  { "left",   1000 },
  { "return", 1000 },
  { "return", 15000 }, -- race reload before next cycle
}

return {
  bind = "SUPER + X",
  window = "Forza Horizon",
  run = function(m)
    for cycle = 1, CYCLES do
      for i, s in ipairs(steps) do
        local what, gap = s[1], s[2]
        if what == "down" then
          m.down("w")
        elseif what == "up" then
          m.up("w")
        else
          m.press(what)
        end

        if i == #steps then
          if cycle == CYCLES then
            return m.exec("say -e -u critical 'Forza done'")
          end
          m.exec("say 'Forza cycle " .. cycle .. "/" .. CYCLES .. "'")
        end
        m.sleep(gap)
      end
    end
  end,
}
