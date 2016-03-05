-- rainbow

-- source: http://www.krishnamani.in/color-codes-for-rainbow-vibgyor-colours/
-- adjusted for grb
off = string.char(0, 0, 0)
red = string.char(0, 255, 0)
orange = string.char(127, 255, 0)
yellow = string.char(255, 255, 0)
green = string.char(255, 0, 0)
blue = string.char(0, 0, 255)
indigo = string.char(0, 75, 130)
violet = string.char(0, 148, 211)
on = string.char(255, 255, 255)


interval = 100
patterns = {
    red .. orange .. yellow .. green,
    orange .. yellow .. green .. blue,
    yellow .. green .. blue .. indigo,
    green .. blue .. indigo .. violet,
    blue .. indigo .. violet .. red,
    indigo .. violet .. red .. orange,
    violet .. red .. orange .. yellow,
}

leds = ws2812.newBuffer(4)
leds:fill(0, 0, 0)
id = 0
tmr.alarm(0, interval, tmr.ALARM_SEMI, function()
    id = (id % table.getn(patterns)) + 1
    leds:set(0, patterns[id])
    leds:write(0)
    -- restart timer, and re-set interval
    tmr.interval(0, interval)
    tmr.start(0)
end)
