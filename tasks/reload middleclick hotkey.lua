function restartMiddleClick()
    local app = hs.application.get('MiddleClick')

    if app ~= nil then
        app.kill9(app)
    end

    hs.timer.delayed.new(0.5, function()
        hs.application.open('MiddleClick')
    end):start()
end

-- Cmd + Alt + Ctrl + M to reload MiddleClick app
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "M", function()
    restartMiddleClick()
    hs.alert.show("MiddleClick restarted!")
end)

function recurrentRestart()
    restartMiddleClick()
    hs.timer.doAfter(10, recurrentRestart)
end

recurrentRestart()