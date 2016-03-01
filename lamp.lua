base64 = require 'base64'
conf = require 'config'
leds = ws2812.newBuffer(conf.device_1.ledcount)
leds:fill(0,0,0)

mqttcommands = {}

-- main loop
tmr.register(conf.device_1.timer_id, 1000 / conf.device_1.refresh, tmr.ALARM_AUTO, function()
    leds:write(conf.device_1.pin)
end)

broker = mqtt.Client(wifi.sta.getmac(), conf.mqtt.keepalive, conf.mqtt.username, conf.mqtt.password, 1)
broker:lwt('activity', wifi.sta.getmac() .. ' offline', 0, 0)

announce = function(client, topic, message)
    client:publish(topic, message, 0, 0, function(client)
        print(string.format('sent "%s" to topic "%s"', message, topic))
    end)
end

subscribe = function(client, topic)
    client:subscribe(topic, 0, function(client)
        print(string.format('mqtt: subscribed to topic "%s"', topic))
    end)
end

broker:on('connect', function(client)
    print(string.format('mqtt: connected to %s:%u ssl=%s',
        conf.mqtt.broker_ip, conf.mqtt.broker_port,
        tostring(conf.mqtt.broker_use_ssl))
    )
    -- subscribe to main topic
    subscribe(client, 'devices/' .. wifi.sta.getmac())

    -- announce we're here
    announce(client, 'announce', string.format('hello id=%s type=%s leds=%u order=rgb',
        wifi.sta.getmac(), conf.device_1.type, conf.device_1.ledcount))
end)

broker:on('message', function(client, topic, data)
    if data == nil then
        print('mqtt: no data in message')
    else
        local cmd, paramstr = string.match(data, '([^%s]+)%s*(.*)$')
        print('mqtt: command="' .. cmd .. '"')

        local params = {}
        for word in string.gmatch(paramstr, '[a-zA-Z0-9%+/]+') do
            print(" param: " .. word)
            table.insert(params, word)
        end

        if mqttcommands[cmd] ~= nil then
            mqttcommands[cmd](client, topic, params)
        end
    end
end)

broker:on('offline', function(client)
    print (string.format('mqtt: offline, reconnecting in %u seconds', conf.mqtt.reconnect_wait))
    tmr.alarm(3, 1000 * conf.mqtt.reconnect_wait, tmr.ALARM_SINGLE, function()
        broker:connect(conf.mqtt.broker_ip, conf.mqtt.broker_port, conf.mqtt.broker_use_ssl)
    end)
end)

wifi.setmode(wifi.STATION)
wifi.sta.config(conf.wificlient.network, conf.wificlient.password, 0)

wifi.sta.eventMonReg(wifi.STA_IDLE, function() print('wificlient: idle') end)
wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() print('wificlient: wrong password') end)
wifi.sta.eventMonReg(wifi.STA_FAIL, function() print('wificlient: failed') end)

wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function()
    print('wificlient: access point not found! retrying in 10 seconds')
    tmr.alarm(2, 10000, tmr.ALARM_SINGLE, function()
        wifi.sta.connect()
    end)
end)

wifi.sta.eventMonReg(wifi.STA_CONNECTING, function()
    local ssid, password, bssid_set, bssid = wifi.sta.getconfig()
    print(string.format('wificlient: connecting ssid="%s"', ssid))
end)

wifi.sta.eventMonReg(wifi.STA_GOTIP, function()
    local ip, nm, gw = wifi.sta.getip()
    print(string.format('wificlient: connected ip=%s/%s gw=%s', ip, nm, tostring(gw)))
    broker:connect(conf.mqtt.broker_ip, conf.mqtt.broker_port, conf.mqtt.broker_use_ssl)
end)

wifi.sta.eventMonStart(1000)

mqttcommands.pattern = function(client, topic, params)
    leds:set(0, base64.dec(params[1]))
end

mqttcommands.off = function(client, topic, params)
    local times = 8

    tmr.alarm(conf.device_1.aux_timer_id, 1000 / conf.device_1.refresh, tmr.ALARM_AUTO, function()
        if times >= 0 then
            leds:fade(2)
            times = times - 1
        else
            tmr.stop(conf.device_1.aux_timer_id)
            tmr.unregister(conf.device_1.aux_timer_id)
            leds:fill(0,0,0)
            announce(client, 'announce', 'off')
        end
    end)
end

mqttcommands.emit = function(client, topic, params)
    r,g,b = tonumber(params[1]), tonumber(params[2]), tonumber(params[3])
    leds:fill(g,r,b)
    announce(client, 'announce', string.format('emit r=%u g=%u, b=%u', r, g, b))
end

mqttcommands.restart = function(client, topic, params)
    announce(client, 'announce', 'restart')

    tmr.alarm(2, 1000, tmr.ALARM_SINGLE, function()
        client:close()
        node.restart()
    end)
end

wifi.sta.connect()
tmr.start(conf.device_1.timer_id)
