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
logger.d('Working')

for i, hotkey in ipairs(appHotkeys) do
    local key = hotkey[1]
    local applicationName = hotkey[2]

    if type(applicationName) == "function" then
        hyper:bind({}, key, applicationName)
    elseif type(applicationName) == "table" then
        local appNameIndexes = {}
        for k, v in pairs(applicationName) do
            appNameIndexes[v] = k
        end
        
        hyper:bind({}, key, function()
            local apps = hs.application.runningApplications()
            local frontMostApp

            for key, app in pairs(apps) do
                if app.isFrontmost(app) then
                    frontMostApp = app
                end
            end

            if frontMostApp ~= nil then
                local title = frontMostApp.title(frontMostApp)
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