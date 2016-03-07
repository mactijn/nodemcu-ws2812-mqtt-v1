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

pattern = red .. orange .. yellow .. green .. blue .. indigo .. violet .. black

interval = 1000
ledcount = 3
leds = ws2812.newBuffer(ledcount)
tmr.alarm(0, interval, tmr.ALARM_SEMI, function()
    -- write first part of pattern
    leds:set(0, pattern:sub(1, ledcount * 3))
    leds:write(0)
    pattern = pattern:sub(4) .. pattern:sub(1, 3)
    -- restart timer, and re-set interval
    tmr.interval(0, interval)
    tmr.start(0)
end)
