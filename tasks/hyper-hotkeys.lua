-- Hyper hotkeys
local HYPER_KEY = 'F17' -- F17 is remapped to Caps Lock with Karabiner-Elements

-- A global variable for the Hyper Mode
local hyper = hs.hotkey.modal.new()

local appHotkeys = {
  { "c", 'Google Chrome' },
  { "t", 'iTerm' },
  { "s", 'Slack' },
  { "v", 'Visual Studio Code' },
  { "d", 'Microsoft Outlook' },
  { "e", 'Finder' },
}

local logger = hs.logger.new('AppHotkeys', 'debug')

for i, hotkey in ipairs(appHotkeys) do
    local key = hotkey[1]
    local applicationName = hotkey[2]

    hyper:bind({}, key, function()
        hs.application.open(applicationName)
    end)
end

-- Enter Hyper Mode when Hyper/Capslock is pressed
function enterHyperMode()
    hyper:enter()
end
  
-- Leave Hyper Mode when Hyper/Capslock is pressed,
function exitHyperMode()
    hyper:exit()
end
  
-- Bind the Hyper key
hs.hotkey.bind({}, HYPER_KEY, enterHyperMode, exitHyperMode)