-- Hyper hotkeys
local HYPER_KEY = 'F17' -- F17 is remapped to Caps Lock with Karabiner-Elements

-- A global variable for the Hyper Mode
local hyper = hs.hotkey.modal.new()

local appHotkeys = {
  { "c", function() 
            -- Checks if Brave app exists. If it doesn't, opens Chrome
            local braveExists = hs.application.launchOrFocus('Brave Browser')
            if not braveExists then
                hs.application.launchOrFocus('Google Chrome')
            end
        end },
  { "t", 'iTerm' },
  { "s", {'Slack', 'Spotify'} },
  { "v", 'Visual Studio Code' },
  { "d", 'Microsoft Outlook' },
  { "e", 'Finder' },
  { "f", 'Firefox' },
  { "b", 'Bouncer Todo List' },
  { "w", function() 
            -- Checks if Whatsapp app exists. If it doesn't, add a hotkey to open Whatsapp Web
            local whatsappExists = hs.application.launchOrFocus('Whatsapp')
            if not whatsappExists then
                hs.urlevent.openURL('https://web.whatsapp.com')
            end
        end },
  { "l", function() hs.caffeinate.startScreensaver() end },
  { "r", function() hs.reload() end },
}

local logger = hs.logger.new('AppHotkeys', 'debug')


--- Generates a table with the values in the place of the keys
-- @param {table} Table to retrieve the indexes
-- @return A table
function getTableIndexes(table)
    local tableIndexes = {}

    for k, v in pairs(table) do
        tableIndexes[v] = k
    end
    
    return tableIndexes
end

for i, hotkey in ipairs(appHotkeys) do
    local key = hotkey[1]
    local applicationName = hotkey[2]

    if type(applicationName) == "function" then
        hyper:bind({}, key, applicationName)
    elseif type(applicationName) == "table" then
        local appNameIndexes = getTableIndexes(applicationName)
        
        hyper:bind({}, key, function()
            local app1 = hs.application.find(applicationName[1]:lower())
            local app2 = hs.application.find(applicationName[2]:lower())
            local appToOpen = nil

            if (app1 ~= nil and not app1:isFrontmost()) or (app1 == nil and app2 == nil) or (app2 ~= nil and app2:isFrontmost()) then
                appToOpen = applicationName[1]
            else
                appToOpen = applicationName[2]
            end
            
            logger.df("Opening %s", appToOpen)
            hs.application.launchOrFocus(appToOpen)
        end)
    else
        hyper:bind({}, key, function()
            logger.df("Opening %s", applicationName)
            hs.application.launchOrFocus(applicationName)
        end)
    end
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