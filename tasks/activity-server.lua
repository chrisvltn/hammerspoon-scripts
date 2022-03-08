local logger = hs.logger.new('Activity Server', 'debug');
local Server = hs.httpserver.new();
Server:setPort(7645);

local activityPath = "./activity.json";
local timeout = 60 * 5; -- 2 minutes
local lastTimeChange = nil;
Timer = nil;
TapListener = nil;
LockWatcher = nil;
ActivityChange = {};

local previousActivityRecord = hs.json.read(activityPath);
if previousActivityRecord ~= nil then
    ActivityChange = previousActivityRecord;
end

local isAvailable = true;

if ActivityChange[#ActivityChange] ~= nil then
    lastTimeChange = ActivityChange[#ActivityChange].time;
    isAvailable = ActivityChange[#ActivityChange].availability;
end

function setAvailability(availability)
    if isAvailable == availability then
        return;
    end

    local timeDiff = "";
    local now = math.floor(hs.timer.secondsSinceEpoch() * 1000);

    if lastTimeChange ~= nil then
        local diff = math.ceil((now - lastTimeChange) / 1000);
        local hours = math.floor(diff / (60*60));
        diff = diff - (hours * (60*60));
        local minutes = math.floor(diff / 60);
        timeDiff = hours .. "h" .. " " .. minutes .. "m";
    end

    if isAvailable then
        logger.df("Setting as AFK");
        hs.alert.show("AFK...");
    else
        logger.df("Setting as working");
        hs.alert.show("Welcome back. " .. timeDiff);
    end

    isAvailable = availability;
    lastTimeChange = now;
    table.insert(ActivityChange, {
        time = lastTimeChange,
        availability = isAvailable,
        diff = timeDiff,
    });
    hs.json.write(ActivityChange, activityPath, true, true);
end

function restartServer()
    Server:stop();

    if TapListener ~= nil then
        TapListener:stop();
    end

    if LockWatcher ~= nil then
        LockWatcher:stop();
    end

    function resetTimeout()
        if Timer ~= nil then
            Timer:stop();
        end

        Timer = hs.timer.doAfter(timeout, function()
            setAvailability(false);
        end);

        Timer:start();
    end

    TapListener = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.mouseMoved }, function (ev)
        setAvailability(true);
        resetTimeout();
    end);
    TapListener:start();

    Server:setCallback(function()
        local response = hs.json.encode(ActivityChange);
        return response, 200, { ["Content-Type"] = "application/json" };
    end);

    LockWatcher = hs.caffeinate.watcher.new(function(ev)
        if ev == hs.caffeinate.watcher.screensaverDidStart
        or ev == hs.caffeinate.watcher.screensDidLock
        or ev == hs.caffeinate.watcher.screensDidSleep
        or ev == hs.caffeinate.watcher.systemWillPowerOff
        or ev == hs.caffeinate.watcher.systemWillSleep then
            setAvailability(false);
        end
    end);

    resetTimeout();
    Server:start();
    LockWatcher:start();
    logger.df("Server started");
end

hs.timer.doEvery(60, restartServer):start();
restartServer();