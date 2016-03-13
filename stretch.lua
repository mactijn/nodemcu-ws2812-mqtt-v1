-- rainbow

-- source: http://www.krishnamani.in/color-codes-for-rainbow-vibgyor-colours/
-- adjusted for grb
red = string.char(0, 255, 0)
orange = string.char(127, 255, 0)
yellow = string.char(255, 255, 0)
green = string.char(255, 0, 0)
blue = string.char(0, 0, 255)
indigo = string.char(0, 75, 130)
violet = string.char(0, 148, 211)
white = string.char(255, 255, 255)
black = string.char(0, 0, 0)

src_pattern = red .. orange .. yellow .. green .. blue .. indigo

interval = 25
ledcount = 30
steps = ledcount

pattern = ''
for pos=0, src_pattern:len() - 1, 3 do
    for step=0, steps - 1 do
        local total_weight = 100 * steps;
        local src_weight = 100 * (steps - step);
        local tgt_weight = 100 * step;

        local src = { src_pattern:byte(pos + 1, pos + 3) }

        local tgt = {}
        if pos + 3 < src_pattern:len() then tgt = { src_pattern:byte(pos + 4, pos + 6) }
        else tgt = { src_pattern:byte(1, 3) }
        end

        pattern = pattern .. string.char(
            ((src[1] * src_weight) + (tgt[1] * tgt_weight)) / total_weight,
            ((src[2] * src_weight) + (tgt[2] * tgt_weight)) / total_weight,
            ((src[3] * src_weight) + (tgt[3] * tgt_weight)) / total_weight
        )
    end
    collectgarbage()
end

leds = ws2812.newBuffer(ledcount)

tmr.register(0, interval, tmr.ALARM_AUTO, function()
    -- fix up pattern if it has the wrong length
    pattern = pattern:rep(((ledcount * 3) / pattern:len()) + 1)
    leds:set(0, pattern:sub(1, ledcount * 3))
    leds:write(0)
    pattern = pattern:sub(-3) .. pattern:sub(1, -4)
    -- pattern = pattern:sub(4) .. pattern:sub(1, 3)
end)

tmr.start(0)
