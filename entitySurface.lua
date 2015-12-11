--[[
entitySurface is a class for surfaces* "inside" entities**, . For example you can have a assembling machine with a surface/pocket dimension where you can build a mini factory, or a train where you can build in the inside area/dimension

This class is easily expandable, for example see nesttSurface.lua

* 'surfaces' are the factorio equivalent to minecraft 'dimensions'
** entities are everything thats not an item in your inventory, ranging from a biter to an assembling machine

2015 XiaoHong
]]


entitySurface = {}

--[[populate this with a table where 
entityData = {
	entityName = { name = "entityName", mapGenSettings = {width = #, height = #},
	the makeSurface will build the surface based on these rules.
]]
entitySurface.entityData = {}

function entitySurface:new(o)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      return o
end

--initialize the global values we need, this will be called by control.on_init
--[[
--globals are stored in this format:
global.entitySurfaceData = {
	validIndex = 1, 
	savedSurfaces = {
		[surfaceName] = {
			surface = surface, 
			entity = entity, 
			surfaceData = {data that you can use and retrieve}
		}
	}
}
--]]


onInit_functions.entitySurfaceIni = function ()
	if global.entitySurfaceData ~= nil then return nil end
	global.entitySurfaceData = {validIndex = 1, savedSurfaces = {}}
end

--override this for your own prefix
entitySurface.surfacePrefix = "entitySurface_"

--override this function with your own entity check in your class
function entitySurface:canHaveSurface (entity)
	printErr(" canHaveSurfaceDummy")
	return true
end

--This matches the entity with a list of saved surfaces to find a match
function entitySurface:getSurfaceByEntity  (entity)
	if not self:canHaveSurface(entity) then 
	return nil end
	for k,v in pairs(global.entitySurfaceData.savedSurfaces) do
		if v.entity == entity then
			return v.surface
		end
	end
	return nil
end

function entitySurface:getEntityBySurface (surface)
	for k,v in pairs(global.entitySurfaceData.savedSurfaces) do
		if v.surface == surface then
			return v.entity
		end
	end
	return nil
end

function entitySurface:enterSurface  (player,surface,pos)
	if pos == nil then pos = {0,0} end
	if surface == nil then printErr("ERROR, attempting to enter nil surface") return nil end
	player.teleport(pos,surface)
end

function entitySurface:enterSurfaceByName  (player,name,pos)
	self:enterSurface(player, game.surfaces.name, pos)
end

function entitySurface:enterSurfaceByEntity  (player,entity, pos)
	if entity == nil or not self:canHaveSurface(entity) then return nil end
	local surf = self:getSurfaceByEntity(entity)
	if surf == nil then
		surf = self:makeSurface(entity)
	end
	if surf == nil then error("called makeSurface from enterSurfaceByEntity but returned nil") return nil end
	self:enterSurface(player, self:getSurfaceByEntity(entity), pos)
end

--make a surface name it entitySurface_# and save it to global.entitySurfaceData.savedSurfaces
 
function entitySurface:makeSurface(entity,mapGenSettings)
	if not self:canHaveSurface(entity) then return nil end
	--check if surface has already been created
	if self:getSurfaceByEntity(entity) ~= nil then return nil end
	local data = global.entitySurfaceData
	local validIndex = data.validIndex
	repeat
		name = self.surfacePrefix .. validIndex
		validIndex = validIndex + 1
	until game.surfaces[name] == nil
	data.validIndex = validIndex
	
	if mapGenSettings == nil then 
		for k,v in pairs(self.entityData) do
			if v.name == entity.name then
				mapGenSettings = v.mapGenSettings
				break
			end
		end
	end
	if mapGenSettings == nil then 
		newSurf = game.create_surface(name)
	else
		newSurf = game.create_surface(name, mapGenSettings)
	end
	remote.call("RSO", "ignoreSurface", name)
	data.savedSurfaces[name] = {surface = newSurf, entity = entity, surfaceData = {}}
	return newSurf
end

--Checks if entity is in one of the saved surfaces
function entitySurface:isInEntitySurface (entity)
	surf = entity.surface
	for k,v in pairs (global.entitySurfaceData.savedSurfaces) do
		if surf == v.surface then return true end
	end
	return false
end

--is this surface a saved entitySurface
function entitySurface:isEntitySurface (surface)
	if surface.name == "nauvis" then return false end
	for k,v in pairs(global.entitySurfaceData.savedSurfaces) do
		if v.surface == surface then
			return true
		end
	end
	return false
end

function entitySurface:hasClassPrefix (surface,prefix)
	prefix = prefix or self.surfacePrefix
	if string.find(surface.name, prefix) then return true end
	return false
end

function entitySurface:getSurfaceTable(surfaceName)
	if surfaceName.name then surfaceName = surfaceName.name end
	return global.entitySurfaceData.savedSurfaces[surfaceName]
end

function entitySurface:requestChunkGen(surface, radius, pos)
	if not surface then printErr("requestChunkGen to a nil surface") return end
	pos = pos or {0,0}
	surface.request_to_generate_chunks(pos,radius)
end