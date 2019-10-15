-- Hyper hotkeys
local HYPER_KEY = 'F17' -- F17 is remapped to Caps Lock with Karabiner-Elements

-- A global variable for the Hyper Mode
local hyper = hs.hotkey.modal.new()

local appHotkeys = {
  { "c", 'Google Chrome' },
  { "t", 'iTerm' },
  { "s", {'Slack', 'Spotify'} },
  { "v", 'Visual Studio Code' },
  { "d", 'Microsoft Outlook' },
  { "e", 'Finder' },
  { "l", function() hs.caffeinate.startScreensaver() end },
}

local logger = hs.logger.new('AppHotkeys', 'debug')

--- Gets the front-most open app
-- @return `hs.application` or `nil` if no app is a front-most one
function getFocusedApp()
    local apps = hs.application.runningApplications()
    local frontMostApp = nil

    for key, app in pairs(apps) do
        if app.isFrontmost(app) then
            frontMostApp = app
        end
    end

    return frontMostApp
end

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
            local focusedApp = hs.application.frontmostApplication()

            if focusedApp ~= nil then
                local title = focusedApp.title(focusedApp)
                local index = appNameIndexes[title]

                if index == nil or applicationName[index + 1] == nil then
                    logger.df("Opening %s", applicationName[1])
                    hs.application.open(applicationName[1])
                else
                    logger.df("Opening %s", applicationName[index + 1])
                    hs.application.open(applicationName[index + 1])
                end
            end
        end)
    else
        hyper:bind({}, key, function()
            hs.application.open(applicationName)
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