ledcount = 3
interval = 20
pause = 200
steps = 25

-- set up led buffer
leds = ws2812.newBuffer(ledcount)
leds:fill(0,0,0)
leds:write(0)

-- source: http://www.krishnamani.in/color-codes-for-rainbow-vibgyor-colours/
red = { 255, 0, 0 }
orange = { 255, 127, 0 }
yellow = { 255, 255, 0 }
green = { 0, 255, 0 }
blue = { 0, 0, 255 }
indigo = { 75, 0, 130 }
violet = { 148, 0, 211 }
white = { 255, 255, 255 }
black = { 0, 0, 0 }


patterns = {
    { red, orange, yellow, green, blue, indigo, violet },
    { orange, yellow, green, blue, indigo, violet, red },
    { yellow, green, blue, indigo, violet, red, orange },
    { green, blue, indigo, violet, red, orange, yellow },
    { blue, indigo, violet, red, orange, yellow, green },
    { indigo, violet, red, orange, yellow, green, blue },
    { violet, red, orange, yellow, green, blue, indigo },
}

step = 1
tmr.alarm(0, interval, tmr.ALARM_SEMI, function()

    -- implement logaritmic fade
    local previous_weight = 100 * (steps - step);
    local current_weight = 100 * (step - 1);
    local fade_weight = 100 * (steps - 1);

    for i = 1, ledcount, 1 do
      -- we adjust for grb here
      leds:set(i - 1,
        (((patterns[2][i][2] * current_weight) + (patterns[1][i][2] * previous_weight)) / fade_weight),
        (((patterns[2][i][1] * current_weight) + (patterns[1][i][1] * previous_weight)) / fade_weight),
        (((patterns[2][i][3] * current_weight) + (patterns[1][i][3] * previous_weight)) / fade_weight)
      )
    end

    leds:write(0)

    if step == steps then
        -- perform transform for next fade
        table.insert(patterns, table.remove(patterns, 1))
        if interval > pause then pause = interval end
        tmr.interval(0, pause)
    else
        if interval < 20 then interval = 20 end
        tmr.interval(0, interval)
    end
    tmr.start(0)
    step = step % steps + 1
    collectgarbage()
end)
