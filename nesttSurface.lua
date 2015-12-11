require "nesttChunkGen"
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
	self:enterSurface( player, train.surface, train.position)
	player.driving = true
end

function nesttSurface:enterNesttSurface(player)
	if global.generatingSurface then return end
	local train = self:getNesttTrainPlayerIsIn(player)
	if train == nil then printErr("train nil") return end
	if not self:getSurfaceByEntity(train) then
		local surf = self:makeSurface(train)
		--self:enterSurfaceByEntity(player, train)
		global.generatingSurface = true
		self:requestChunkGen(surf, 2)
		local surfName = surf.name
		local prog = gui.createProgressBar(player)
		local closure = pClosure.new("surfaceGen")
		closure.progress = function(funcName)
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
			global.onTickFunctions["progress"] = nil 
			end
		end
		
		global.onTickFunctions["progress"] = function(funcName)
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
				self:enterSurfaceByEntity(player, train)
				gui.destroyProgressBar(player)
			end
		)
		return
	end
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

function nesttSurface:onPlayerDrivingChangedState(event)
	local player = game.players[event.player_index]
	if (player.vehicle ~= nil and player.vehicle.name == locomotive.name) then
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



