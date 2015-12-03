require "nesttChunkGen"
nesttSurface = entitySurface:new()

local dummyFun = function () error("dummy function called, maybe you forgot to remove 'local' from function body?") end

local getNesttTrainPlayerIsIn = function (self,player)
	if not self:canHaveSurface(player.vehicle) then
	return nil end
	return player.vehicle
end

local canHaveSurface = function(self,entity)
	if entity and entity.name == locomotive.name then
		return true 
	end
	return false
end

local exitNesttSurface = function(self,player)
	local train = self:getEntityBySurface(player.surface)
	if train == nil then return nil end
	self:enterSurface( player, train.surface, train.position)
	player.driving = true
end

local enterNesttSurface = function(self,player)
	local train = self:getNesttTrainPlayerIsIn(player)
	if train == nil then printErr("train nil") return end
	self:enterSurfaceByEntity(player, train)
end

local enterExit = function(self,player)
	if not self:isInEntitySurface(player) then
		self:enterNesttSurface(player)
	else
		self:exitNesttSurface(player)
	end
end

nesttSurface.createGui = function (player)
	if player.gui.left.nestt == nil then
		gui.createGui(player)
	end
end


local onPlayerDrivingChangedState = function (self,event)
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

for k,v in pairs({
exitNesttSurface = exitNesttSurface,
enterNesttSurface = enterNesttSurface,
enterExit = enterExit,
canHaveSurface = canHaveSurface,
onPlayerDrivingChangedState = onPlayerDrivingChangedState,
getNesttTrainPlayerIsIn = getNesttTrainPlayerIsIn,

entityData = nesttConfig.entityData,
surfacePrefix = nesttConfig.surfacePrefix,
}) do 
	nesttSurface[k] = v
end

