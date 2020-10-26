
--- === HammerText ===
--- Based on: https://github.com/Hammerspoon/hammerspoon/issues/1042
--- 
--- How to "install":
--- - Simply copy and paste this code in your "init.lua".
--- 
--- How to use:
--- 	- Add this init.lua to ~/.hammerspoon/Spoons/HammerText.spoon
--- 	- Add your hotstrings (abbreviations that get expanded) to the "keywords" list following the example format.
--- 	
--- 	ht = hs.loadSpoon("HammerText")
--- 	ht.keywords ={
--- 			nname = "Max Rydahl Andersen",
--- 			xdate = function() return os.date("%B %d, %Y") end,
--- 	}
--- 	ht:start()
--- 
--- 
--- 
--- Features:
--- - Text expansion starts automatically in your init.lua config.
--- - Hotstring expands immediately.
--- - Word buffer is cleared after pressing one of the "navigational" keys.
--- 	PS: The default keys should give a good enough workflow so I didn't bother including other keys.
--- 			If you'd like to clear the buffer with more keys simply add them to the "navigational keys" conditional.
--- 
--- Limitations:
--- - Can't expand hotstring if it's immediately typed after an expansion. Meaning that typing "..name..name" will result in "My name..name".
--- 	This is intentional since the hotstring could be a part of the expanded string and this could cause a loop.
--- 	In that case you have to type one of the "buffer-clearing" keys that are included in the "navigational keys" conditional (which is very often the case).

HammerText = {}
HammerText.__index = HammerText

-- Metadata
HammerText.name = "HammerText"
HammerText.version = "1.0"
HammerText.author = "Multiple Authors"

--- HammerText.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
HammerText.logger = hs.logger.new('HammerText', 'debug')

--- HammerText.keywords
--- Variable
--- Map of keywords to strings or functions that return a string
--- to be replaced.
HammerText.keywords = {
	["..name"] = "My name",
	["..addr"] = "My address",
}

HammerText.watchers = {}
HammerText.watchersIndex = 1
HammerText.keyMap = require"hs.keycodes".map

function expander()
	HammerText.watchersIndex = HammerText.watchersIndex + 1

	HammerText.watchers[HammerText.watchersIndex] = {}
	HammerText.watchers[HammerText.watchersIndex].word = ""
	HammerText.watchers[HammerText.watchersIndex].isExpanding = false
	HammerText.watchers[HammerText.watchersIndex].currentOutput = ""
	HammerText.watchers[HammerText.watchersIndex].finalOutput = ""
	
	-- create an "event listener" function that will run whenever the event happens
	HammerText.watchers[HammerText.watchersIndex].listener = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(ev)
		local keyCode = ev:getKeyCode()
		local char = ev:getCharacters()
		local flags = ev:getFlags()

		if HammerText.watchers[HammerText.watchersIndex].isExpanding == true then
			if keyCode == HammerText.keyMap["delete"] then
				return false
			end
			
			HammerText.watchers[HammerText.watchersIndex].currentOutput = HammerText.watchers[HammerText.watchersIndex].currentOutput .. char
			HammerText.logger.d("Is expanding")
			HammerText.logger.df("Current expansion '%s' (%s)", HammerText.watchers[HammerText.watchersIndex].currentOutput, string.len(HammerText.watchers[HammerText.watchersIndex].currentOutput))
			HammerText.logger.df("Final expansion '%s' (%s)", HammerText.watchers[HammerText.watchersIndex].finalOutput, string.len(HammerText.watchers[HammerText.watchersIndex].finalOutput))
			
			if HammerText.watchers[HammerText.watchersIndex].currentOutput == HammerText.watchers[HammerText.watchersIndex].finalOutput then
				HammerText.logger.d("Finished expansion")
				HammerText.watchers[HammerText.watchersIndex].currentOutput = ""
				HammerText.watchers[HammerText.watchersIndex].finalOutput = ""
				HammerText.watchers[HammerText.watchersIndex].isExpanding = false
			end

			return false
		end
		
		-- if "delete" key is pressed
		if keyCode == HammerText.keyMap["delete"]
		or keyCode == HammerText.keyMap["left"] then
			if flags["cmd"]
			or flags["alt"] then
				HammerText.watchers[HammerText.watchersIndex].word = ""
				return false
			end
			
			if #HammerText.watchers[HammerText.watchersIndex].word > 0 then
				-- remove the last char from a string with support to utf8 characters
				local t = {}
				for _, chars in utf8.codes(HammerText.watchers[HammerText.watchersIndex].word) do table.insert(t, chars) end
				table.remove(t, #t)
				HammerText.watchers[HammerText.watchersIndex].word = utf8.char(table.unpack(t))
				HammerText.logger.df("Word after deleting: %s", HammerText.watchers[HammerText.watchersIndex].word)
			end
			return false -- pass the "delete" keystroke on to the application
		end

		-- if one of these "navigational" keys is pressed
		if keyCode == HammerText.keyMap["return"]
		or keyCode == HammerText.keyMap["cmd"]
		or flags["cmd"]
		or keyCode == HammerText.keyMap["alt"]
		or keyCode == HammerText.keyMap["F17"]
		or keyCode == HammerText.keyMap["tab"]
		or keyCode == HammerText.keyMap["space"]
		or keyCode == HammerText.keyMap["up"]
		or keyCode == HammerText.keyMap["down"]
		or keyCode == HammerText.keyMap["right"] then
			HammerText.watchers[HammerText.watchersIndex].word = "" -- clear the buffer
			return false
		end

		-- append char to "word" buffer
		HammerText.watchers[HammerText.watchersIndex].word = HammerText.watchers[HammerText.watchersIndex].word .. char
		HammerText.logger.df("Word after appending: %s", HammerText.watchers[HammerText.watchersIndex].word)

		HammerText.logger.df("Word to check if hotstring: %s", HammerText.watchers[HammerText.watchersIndex].word)

		-- finally, if "word" is a hotstring
		local output = HammerText.keywords[HammerText.watchers[HammerText.watchersIndex].word]
		if type(output) == "function" then -- expand if function
			local _, o = pcall(output)
			if not _ then
				HammerText.logger.ef("~~ expansion for '" .. what .. "' gave an error of " .. o)
				-- could also set o to nil here so that the expansion doesn't occur below, but I think
				-- seeing the error as the replacement will be a little more obvious that a print to the
				-- console which I may or may not have open at the time...
				-- maybe show an alert with hs.alert instead?
			end
			output = o
		end

		if output then
			-- delete the abbreviation
			for i = 1, utf8.len(HammerText.watchers[HammerText.watchersIndex].word), 1 do 
				hs.eventtap.keyStroke({}, "delete", 0) 
			end 

			-- starts expansion
			HammerText.watchers[HammerText.watchersIndex].isExpanding = true
			HammerText.watchers[HammerText.watchersIndex].finalOutput = output
			hs.eventtap.keyStrokes(output) -- expand the word
			HammerText.watchers[HammerText.watchersIndex].word = "" -- clear the buffer
		end

		return false -- pass the event on to the application
	end):start() -- start the eventtap

	-- return watcher to assign this functionality to the "expander" variable to prevent garbage collection
	return HammerText.watchers[HammerText.watchersIndex].listener
end

--- HammerText:start()
--- Method
--- Start HammerText
---
--- Parameters:
---  * None
function HammerText:start()
	print("Heeey! Hammertext is running")
	expander()
end

return HammerText