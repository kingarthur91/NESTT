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
		
		local r = 8
		local vhead = {0,-3}
		local vR = {0,-r}
		local train = game.player.vehicle
		local point = {train.position.x, train.position.y}

		local theta = train.orientation * math.pi * 2
		vhead = geometry.rotate(vhead, theta)
		vR = geometry.rotate(vR, theta)
		point = geometry.addPos(point,vhead)
		vR = geometry.addPos(point,vR)
		--invisible-chest
		if invis then invis.destroy() invis = nil end
		invis = game.player.surface.create_entity{name = "invisible-chest", position = point}
			
		
		--tri = geometry.makeTriangleFromPointVector( point, vector , width)
		--[[
		for k,v in pairs( tri ) do
			game.player.surface.create_entity{name = "copper-ore-particle", position = v, movement = {0,0},height = 0.01,vertical_speed = 0.05,frame_speed= 1 }
		end--]]
		
		local bbox = geometry.circleBBox(point,r)
		
		for k,v in pairs( bbox ) do
			game.player.surface.create_entity{name = "iron-ore-particle", position = v, movement = {0,0},height = 0.01,vertical_speed = 0.05,frame_speed= 1 }
		end
		
		local ores = game.get_surface(1).find_entities_filtered{area = bbox, type= "resource"}
	
		
		local oresFiltered = geometry.pointsInSemicircle(point,vR ,ores)
		
		
		
		ents = ents or {}
		for k,v in pairs(ents) do
			if v then 
				v.destroy()
			end
		end
		ents = {}
		
		for k,ent in pairs(oresFiltered) do
			local v = {ent.position.x, ent.position.y}
			local movement = geometry.subPos(point,v)
			movement = geometry.scale(movement,0.035)
			local ent = game.player.surface.create_entity({name = "mining-beam", position = v, source_position = {v[1],v[2]+1}, target = invis})
			table.insert(ents,ent)
		end
		--]]
		--debugPrint(_VERSION)
		--l:logTable(_ENV,2)
		--l:dump()
		--[[
		waitTillTrueThenRun( 
			function() 
				if game.player.surface.name ~= "nauvis" then return true end
				return false
			end,
			function()
				game.player.print("left nauvis")
			end
		)
		--]]
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
