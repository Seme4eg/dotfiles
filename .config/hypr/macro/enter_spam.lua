-- enter every 100 ms, forever until toggled off
return {
  bind = "SUPER + ALT + E",
  run = function(m)
    while true do
      m.press("return")
      m.sleep(100)
    end
  end,
}
