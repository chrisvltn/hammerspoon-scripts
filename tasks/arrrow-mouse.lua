local keyMap = require"hs.keycodes".map
local HYPER_KEY = 'F17'
local isPressed = false
local multiplier = 1
local mods = {'alt'}

local logger = hs.logger.new('Arrow Mouse', 'debug')

function move(x, y)
    local position = hs.mouse.getRelativePosition()
    
    x = x * multiplier
    y = y * multiplier

    position.x = position.x + x
    position.y = position.y + y

    hs.mouse.setRelativePosition(position)

    multiplier = multiplier + 1
end

local upKey = hs.hotkey.new(
    mods, 
    'up', 
    function() move(0, -1) end, 
    function() move(0, 0) end, 
    function() move(0, -1) end
)

local downKey = hs.hotkey.new(
    mods,
    'down', 
    function() move(0, 1) end, 
    function() move(0, 0) end, 
    function() move(0, 1) end
)

local leftKey = hs.hotkey.new(
    mods,
    'left', 
    function() move(-1, 0) end, 
    function() move(0, 0) end, 
    function() move(-1, 0) end
)

local rightKey = hs.hotkey.new(
    mods,
    'right', 
    function() move(1, 0) end, 
    function() move(0, 0) end, 
    function() move(1, 0) end
)

hs.hotkey.new(
    mods, 
    HYPER_KEY, 
    function() 
        upKey:enable() 
        downKey:enable() 
        leftKey:enable() 
        rightKey:enable() 
    end, 
    function() 
        upKey:disable()
        downKey:disable()
        leftKey:disable()
        rightKey:disable()
        multiplier = 1
    end
):enable()