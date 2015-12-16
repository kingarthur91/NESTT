require "defines"
require "util"
require "lib"
geometry = require "libs/geometry"
pClosure = require "pClosure"

require "gui"
require "guiScripts"
require "nesttConfig"
require "debugTools"

onInit_functions = {}

nesttMiner = require "nesttMiner"
require "entitySurface"
require "nesttSurface"

logger = require "libs/logger"
l = logger.new_logger()

debug_enabled = true
printErr_enabled = true
debugButton = true

function on_load() on_init() end

function on_init()
	pClosure.init()
	nesttMiner:init()
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
		--debugPrint("nesttDebug")
		local ppos = game.player.position
		local bbox = {{ppos.x,ppos.y},{ppos.x+1,ppos.y+1.4}}
		local pos = geometry.bBoxToTilePos(bbox)
		print(pos)
		for _,p in pairs(pos) do
			game.player.surface.create_entity{name = "tree-02-red", position = {p[1],p[2]}}
		end
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
			if type(fun) == "table" and fun.onTick then fun:onTick(name) end
		end
	end)

--This useful function uses checkFun for a condition check, called on every tick, if it is true it runs runFun and auto deletes itself from the global onTickFunctions table. Don't use closures/upValues in these functions as they will cause loading problems with global
function waitTillTrueThenRun( checkFun, runFun )
	local i = 1
	local funStr = ""
	repeat
		funStr = tostring(checkFun) .. tostring(runFun) .. "_" .. i
		i = i + 1
	until global.onTickFunctions[funStr] == nil
	
	local closure = pClosure.new(funStr)
	closure.checkFun = checkFun
	closure.runFun = runFun
	
	closure.waitTillTrueThenRun = function (myName)
			--load the saved functions
			local closure = pClosure.new(myName)
			local checkFun = closure.checkFun
			local runFun = closure.runFun
			if checkFun() then 
				runFun()
				pClosure.deleteNamespace(myName)
				global.onTickFunctions[myName] = nil
			end
		end
	global.onTickFunctions[funStr] = closure.waitTillTrueThenRun
end
