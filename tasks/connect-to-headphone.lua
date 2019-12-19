local logger = hs.logger.new('Connect to headphones', 'debug')

-- Check and install dependencies if needed
local output, isOK = hs.execute('blueutil -v')

if not isOK then
    hs.execute('brew install blueutil')
end

local BLUETOOTH_DEVICE_NAME = "Bozo"

-- Cmd + Alt + Ctrl + B to reload connect to the headphone
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "B", function()
    hs.alert.show("Connecting to " .. BLUETOOTH_DEVICE_NAME .. "...")
    local output, isOK = hs.execute('system_profiler -json SPBluetoothDataType')
    local devices = hs.json.decode(output).SPBluetoothDataType[1].device_title
    local selectedDevice = nil
    
    for index, device in pairs(devices) do
        for key in pairs(device) do
            if key == BLUETOOTH_DEVICE_NAME then
                selectedDevice = device[key]
                break
            end
        end

        if selectedDevice ~= nil then
            break
        end
    end

    if selectedDevice == nil then
        hs.alert.show(BLUETOOTH_DEVICE_NAME .. " not found")
        return
    end

    local isConnected = selectedDevice.device_isconnected == "attrib_Yes"
    if isConnected then
        hs.alert.show(BLUETOOTH_DEVICE_NAME .. " already connected")
    else
        hs.execute('blueutil --connect ' .. BLUETOOTH_DEVICE_NAME, true)
        hs.alert.show(BLUETOOTH_DEVICE_NAME .. " connected")
    end
end)