require "defines"
require "util"
require "lib"
pClosure = require "pClosure"

require "gui"
require "guiScripts"
require "nesttConfig"
require "debugTools"

onInit_functions = {}

require "entitySurface"
require "nesttSurface"

logger = require "libs/logger"
l = logger.new_logger()

debug_enabled = true
printErr_enabled = true
debugButton = true

function on_load() on_init() end



function on_init()
	global["nesttEntities"] = global["nesttEntities"] or {validIndex = 1}
	for k,v in pairs(onInit_functions) do
		if type(v) == "function" then
			v()
		else
			error("cannot initialize: " .. tostring(k) .. " it is not a function")
		end
	end
	global.onTickFunctions = global.onTickFunctions or {}
	
	global.onTickFunctions["refreshGui"] = function()
		for k,player in pairs(game.players) do
			gui.destroyGui(player)
			nesttSurface.createGui(player)
		end
		global.onTickFunctions["refreshGui"] = nil
	end
	
	
	
	
	
end

debug_i = 1
local function on_gui_click(event)
	gui.onguiClick(event)
	
	local name = event.element.name
	
	if name == "debug" then 
	debugPrint("nesttDebug")
	debugPrint(_VERSION)
	
	l:logTable(_ENV,2)
	l:dump()
	
	local upval = "foo_"
	local someFunc = function(str)
		game.player.print(upval .. str)
	end

	
	closure = pClosure.new()

	if not global.savedFuncName then 
		global.savedFuncName = true
		closure.someFunc = someFunc
		closure.someFunc("bar, save/load then press button again")
		closure.someFunc("bar, second call")
	else 
		closure.someFunc("bar, see, i still work")
		closure.someFunc("bar, second call")
		closure.someFunc = nil --delete the function
		game.player.print("function deleted, call again for error msg")
	end

	
	
	waitTillTrueThenRun(
		function () 
			if game.player.surface.name ~= "nauvis" then 
				return true 
			end 
		return false end,
		function () debugPrint("left nauvis " .. debug_i) debug_i = debug_i + 1 end)
	end
	
end

	
script.on_init(on_init)

script.on_load(on_load)

script.on_configuration_changed(on_configuration_changed)

script.on_event(defines.events.on_player_driving_changed_state, 
	function(event) nesttSurface:onPlayerDrivingChangedState(event) end)

script.on_event(defines.events.on_gui_click, on_gui_click)

script.on_event(defines.events.on_chunk_generated, 
	function(event) nesttSurface:onVanillaGen(event) end)
	
script.on_event(defines.events.on_tick, 
	function(event) 
		for name,fun in pairs(global.onTickFunctions) do
			--we pass the name to the function so it can delete itself if it wants to, the function does not remember its own name to prevent closures
			if type(fun) == "function" then fun(name) end
		end
	end)

--This useful function uses checkFun for a condition check, called on every tick, if it is true it runs runFun and auto deletes itself from the global onTickFunctions table. Don't use closures/upValues in these functions as they will cause loading problems with global
function waitTillTrueThenRun( checkFun, runFun )
	local i = 1
	local funStr = ""
	repeat
		funStr = tostring(runFun) .. "_" .. i
		i = i + 1
	until global.onTickFunctions[funStr] == nil
	--save the functions in global to prevent closures
	global.onTickFunctions[funStr .. "_funTable"] = {checkFun, runFun}
	global.onTickFunctions[funStr] = 
		function (myName)
			--load the saved functions
			local funTableName = myName .. "_funTable"
			local checkFun = global.onTickFunctions[funTableName][1]
			local runFun = global.onTickFunctions[funTableName][2]
			if checkFun() then 
				runFun() 
				global.onTickFunctions[myName] = nil
				global.onTickFunctions[funTableName] = nil
			end
		end
end

-----------TEST CLOSURE----------
--[[
function a()
	local upval = "_world"
	function b(upval,arg1) --upval was an upvalue for b so we pass it in explicitly, 
		debugPrint(arg1 .. upval)
	end
	
	fName = global.pClosure.add(b, upval) --this saves upval so that it will not be nil after load.
	
	global.someName = fName --you should save fName since you will need it to access the function
end

--call before save/load
global.pClosure.call(fName,"hello")

--result: "hello_world"

--save/load game then call
global.pClosure.call(fName,"hello")

--result: error fName is nil
--the correct call
global.pClosure.call(global.fName,"hello")

--result: "hello_world"

--delete the function
global.pClosure.delete(global.fName)
global.fName = nil --not needed anymore

--]]


 
	