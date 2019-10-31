local logger = hs.logger.new('Connect to headphones', 'debug')

-- Check and install dependencies if needed
local output, isOK = hs.execute('blueutil -v', true)

if not isOK then
    hs.execute('brew install blueutil', true)
end

local BLUETOOTH_DEVICE_NAME = "Bozo"

-- Cmd + Alt + Ctrl + B to reload connect to the headphone
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "B", function()
    local output, isOK = hs.execute('blueutil --recent --format json-pretty', true)
    local devices = hs.json.decode(output)

    local selectedDevice = hs.fnutils.find(devices, function (device) 
        return device.name == BLUETOOTH_DEVICE_NAME
    end)

    if selectedDevice.connected then
        hs.alert.show(BLUETOOTH_DEVICE_NAME .. " already connected")
    end
    
    if selectedDevice ~= nil and not selectedDevice.connected then
        hs.alert.show("Connecting to " .. BLUETOOTH_DEVICE_NAME .. "...")
        hs.execute('blueutil --connect ' .. selectedDevice.address, true)
        hs.alert.show(BLUETOOTH_DEVICE_NAME .. " connected")
    end
end)