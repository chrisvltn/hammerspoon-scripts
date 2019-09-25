-- Auto reload config when init.lua is changed
function reloadConfig(files)
	doReload = false
	
	for _,file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	
	if doReload then
		configWatcher:stop()
		hs.reload()
	end
end

configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
configWatcher:start()