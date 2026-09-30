-- space, down, enter x3 with 700 ms between keys, forever until toggled off
local steps = { "space", 400, "down", 150, "return", 450, "return", 550, "return", 600 }

return {
    bind = "SUPER + ALT + X",
    run = function(m)
        for _ = 1, 11 do
            for i, s in ipairs(steps) do
                if type(s) == "number" then
                    m.sleep(s)
                else
                    m.press(s)
                    if steps[i + 1] and type(steps[i + 1]) ~= "number" then
                        m.sleep(500)
                    end
                end
            end
        end
    end,
}
