-- Cmd + Alt + Ctrl + M to reload MiddleClick app
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "M", function()
    local app = hs.application.get('MiddleClick')

    if app ~= nil then
        app.kill9(app)
    end

    hs.application.open('MiddleClick')
    hs.alert.show("MiddleClick restarted!")
end)