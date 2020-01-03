function restartMiddleClick()
    local app = hs.application.get('MiddleClick')

    if app ~= nil then
        app.kill9(app)
    end

    hs.application.open('MiddleClick')
end

-- Cmd + Alt + Ctrl + M to reload MiddleClick app
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "M", function()
    restartMiddleClick()
    hs.alert.show("MiddleClick restarted!")
end)

function recurrentRestart()
    restartMiddleClick()
    hs.timer.doAfter(60, recurrentRestart)
end

recurrentRestart()