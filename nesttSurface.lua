local nesttChunkGen = require "nesttChunkGen"
local geometry = require "libs/geometry"
require "nesttConfig"
nesttSurface = entitySurface:new()

local dummyFun = function () error("dummy function called, maybe you forgot to remove 'local' from function body?") end

nesttSurface.entityData = nesttConfig.entityData

function nesttSurface:getNesttTrainPlayerIsIn(player)
	if not self:canHaveSurface(player.vehicle) then
	return nil end
	return player.vehicle
end

function nesttSurface:canHaveSurface(entity)
	if entity and entity.name == locomotive.name then
		return true 
	end
	return false
end

function nesttSurface:exitNesttSurface(player)
	local train = self:getEntityBySurface(player.surface)
	if train == nil then return nil end
	--teleport the player in front of the train
	local offsetVec = {0,-2.6 -0.01} 
	local theta = train.orientation * math.pi * 2
	offsetVec = geometry.rotate(offsetVec, theta)
	local newPosition = geometry.addPos(train.position,offsetVec)
	self:enterSurface( player, train.surface, newPosition)
	player.driving = true
end

function nesttSurface:makeSurfaceAndEntities(player)
	local train = player.vehicle
	local surf = self:makeSurface(train)
	--self:enterSurfaceByEntity(player, train)
	global.generatingSurface = true
	self:requestChunkGen(surf, 2)
	local surfName = surf.name
	local prog = gui.createProgressBar(player)
	local closure = pClosure.new("surfaceGen")
	closure.progress = 
		function(funcName)
			local count = 0
			local step = 1/8
			for i = -1, 0 do
				for j = -2, 1 do
					if game.surfaces[surfName].is_chunk_generated{i, j} then
						count = count + step
					end
				end
			end
			prog.value = count
			if count >= 0.99 then 
			global.generatingSurface = false
			global.generatedSurface = true
			global.onTickFunctions["progress"] = nil 
			end
		end
	global.onTickFunctions["progress"] = 
		function(funcName)
			local closure = pClosure.new("surfaceGen")
			closure.progress(funcName)
		end
	waitTillTrueThenRun(
		function()
			if prog.value >= 0.99 then return true end
		end,
		function()
			nesttChunkGen:LocomoTilesGen(surf)
			nesttChunkGen:LocomoEntityGen(surf)
			miner = nesttMiner:new(surf)
			--self:enterSurfaceByEntity(player, train)
			self.createGui(player)
			gui.destroyProgressBar(player)
		end
	)
	return
end

function nesttSurface:enterNesttSurface(player)
	local train = self:getNesttTrainPlayerIsIn(player)
	if train == nil then printErr("train nil") return end
	self:enterSurfaceByEntity(player, train)
end

function nesttSurface:enterExit(player)
	if not self:isInEntitySurface(player) then
		self:enterNesttSurface(player)
	else
		self:exitNesttSurface(player)
	end
end

function nesttSurface.createGui(player)
	if player.gui.left.nestt == nil then
		gui.createGui(player)
	end
end

local function gift(player)
	player.insert{name = "nestt-wagon", count = 2}
	print("giving player 2 nestt-wagons")
end

function nesttSurface:onPlayerDrivingChangedState(event)
	local player = game.players[event.player_index]
	if (player.vehicle ~= nil and player.vehicle.name == locomotive.name) then
		if global.generatingSurface then return end
		if not global.generatedSurface then
			self:makeSurfaceAndEntities(player)
			gift(player)
			return 
		end
		self.createGui(player)
	end
	if player.vehicle == nil and player.gui.left.nestt ~= nil and not self:isEntitySurface(player.surface) then
	  gui.destroyGui(player)
	end
end

function nesttSurface:onVanillaGen(event)
	local surface = event.surface
	--check if surface is one of ours
	if not self:isEntitySurface(surface) then return end
	--more specific check if surface is from this class
	if not self:hasClassPrefix(surface) then return end
	local area = areaTrim(event.area)
	nesttChunkGen:generate(surface,area)
end




--locomotive collision_box = {{-0.6, -2.6}, {0.6, 2.6}},

--wagon collision_box = {{-0.6, -2.4}, {0.6, 2.4}},


