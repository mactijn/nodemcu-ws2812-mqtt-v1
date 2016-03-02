-- blink

interval = 100
patterns = {

    string.char(255, 0, 0,  0, 0, 0,    0, 0, 0,    0, 0, 0),
    string.char(64, 0, 0,   255, 0, 0,  0, 0, 0,    0, 0, 0),
    string.char(0, 0, 0,    64, 0, 0,   255, 0, 0,  0, 0, 0),
    string.char(0, 0, 0,    0, 0, 0,    64, 0, 0,   255, 0, 0),
    string.char(0, 0, 0,    0, 0, 0,    0, 0, 0,    255, 0, 0),
    string.char(0, 0, 0,    0, 0, 0,    255, 0, 0,  64, 0, 0),
    string.char(0, 0, 0,    255, 0, 0,  64, 0, 0,   0, 0, 0),
    string.char(255, 0, 0,  64, 0, 0,   0, 0, 0,    0, 0, 0),
    string.char(64, 0, 0,   0, 0, 0,    0, 0, 0,    0, 0, 0),
    string.char(0, 0, 0,    0, 0, 0,    0, 0, 0,    0, 0, 0),

    string.char(0, 255, 0,  0, 0, 0,    0, 0, 0,    0, 0, 0),
    string.char(0, 64, 0,   0, 255, 0,  0, 0, 0,    0, 0, 0),
    string.char(0, 0, 0,    0, 64, 0,   0, 255, 0,  0, 0, 0),
    string.char(0, 0, 0,    0, 0, 0,    0, 64, 0,   0, 255, 0),
    string.char(0, 0, 0,    0, 0, 0,    0, 0, 0,    0, 255, 0),
    string.char(0, 0, 0,    0, 0, 0,    0, 255, 0,  0, 64, 0),
    string.char(0, 0, 0,    0, 255, 0,  0, 64, 0,   0, 0, 0),
    string.char(0, 255, 0,  0, 64, 0,   0, 0, 0,    0, 0, 0),
    string.char(0, 64, 0,   0, 0, 0,    0, 0, 0,    0, 0, 0),
    string.char(0, 0, 0,    0, 0, 0,    0, 0, 0,    0, 0, 0),

    string.char(0, 0, 255,  0, 0, 0,    0, 0, 0,    0, 0, 0),
    string.char(0, 0, 64,   0, 0, 255,  0, 0, 0,    0, 0, 0),
    string.char(0, 0, 0,    0, 0, 64,   0, 0, 255,  0, 0, 0),
    string.char(0, 0, 0,    0, 0, 0,    0, 0, 64,   0, 0, 255),
    string.char(0, 0, 0,    0, 0, 0,    0, 0, 0,    0, 0, 255),
    string.char(0, 0, 0,    0, 0, 0,    0, 0, 255,  0, 0, 64),
    string.char(0, 0, 0,    0, 0, 255,  0, 0, 64,   0, 0, 0),
    string.char(0, 0, 255,  0, 0, 64,   0, 0, 0,    0, 0, 0),
    string.char(0, 0, 64,   0, 0, 0,    0, 0, 0,    0, 0, 0),
    string.char(0, 0, 0,    0, 0, 0,    0, 0, 0,    0, 0, 0),
}

leds = ws2812.newBuffer(4)
id = 1
tmr.alarm(0, interval, tmr.ALARM_SEMI, function()
    leds:set(0, patterns[id])
    leds:write(0)
    id = (id % table.getn(patterns)) + 1
    -- restart timer, and re-set interval
    tmr.interval(0, interval)
    tmr.start(0)
end)
