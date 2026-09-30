-- one-shot menu sequence, 700 ms between keys; a number replaces the gap
local GAP = 600
local steps = {
  "return", "return", 11000, -- list
  -- menu
  "escape", 1000, "down", "return", 700,
  "down", 200, "down", 200, "down", 200, "down", 200, "down", 200, "down", 200, "down", -- 7x down
  "return", 1000,
  -- skills
  "return", 2000, "up", "return", "up", "return", "up",
  "return", "right", "return", "right", "return", 700,
  -- menus
  "escape", 1000, "escape", 1000, "up", "return", 1000,
  "y", "down", 200, "down", 200, "down", 200, "down", 200, "return", 200, "escape"
}

return {
  bind = "SUPER + ALT + C",
  window = "Forza Horizon",
  run = function(m)
    for i, s in ipairs(steps) do
      if type(s) == "number" then
        m.sleep(s)
      else
        m.press(s)
        if steps[i + 1] and type(steps[i + 1]) ~= "number" then
          m.sleep(GAP)
        end
      end
    end
  end,
}
