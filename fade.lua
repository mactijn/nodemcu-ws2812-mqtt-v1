ledcount = 3
interval = 40
pause = 200
steps = 10

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
    rainbow = { red, orange, yellow, green, blue, indigo, violet }
}

pattern = patterns.rainbow

step = 1
tmr.alarm(0, interval, tmr.ALARM_SEMI, function()

    -- implement logaritmic fade
    local previous_weight = 100 * (steps - step);
    local current_weight = 100 * (step - 1);
    local fade_weight = 100 * (steps - 1);

    -- copy pattern, and shift
    tgt_pattern = pattern
    table.insert(tgt_pattern, table.remove(tgt_pattern, 1))

    for i = 1, ledcount, 1 do
      -- we adjust for grb here
      leds:set(i-1,
        (((tgt_pattern[i][2] * current_weight) + (pattern[i][2] * previous_weight)) / fade_weight),
        (((tgt_pattern[i][1] * current_weight) + (pattern[i][1] * previous_weight)) / fade_weight),
        (((tgt_pattern[i][3] * current_weight) + (pattern[i][3] * previous_weight)) / fade_weight)
      )
    end

    leds:write(0)

    if step == steps then
        -- perform transform for next fade
        table.insert(pattern, table.remove(pattern, 1))
        tmr.interval(0, pause)
    else
        tmr.interval(0, interval)
    end
    tmr.start(0)
    step = step % steps + 1
end)
