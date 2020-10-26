-- Keywords expansion
ht = hs.loadSpoon("HammerText")
ht.keywords = {
    ["@date"] = function() return os.date("%Y-%m-%d") end,
    ["@email"] = "chris_valentin@outlook.com",
    ["@wemail"] = "christian.valentin@westwing.de",
    ["@emoji"] = function() hs.eventtap.keyStroke({"cmd", "ctrl"}, "space") end,
    [".shrug."] = "¯\\_(ツ)_/¯",
}
ht:start()