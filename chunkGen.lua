--[[Custom chunkGeneration

2014 xiaoHong
--]]


chunkGen = {}

function chunkGen:new(o)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      return o
end

--area, the bounds of the chunk generated, a table in the format {left_top={x=x1, y=y1}, right_bottom={x=x2,y=y2}}
function chunkGen:setTiles(surface,area,tileName)
	if not surface then printErr("chunkGen:setTiles not a valid surface") return nil end
	local newTiles = {}
	for x, y in iarea(area) do
		table.insert(newTiles, {name = tileName, position = {x, y}})
	end
	surface.set_tiles(newTiles)
end

function chunkGen:setTilesMultiArea(surface,areas,tileName)
	if not surface then printErr("chunkGen:setTiles not a valid surface") return nil end
	local newTiles = {}
	for k,area in pairs(areas) do
		for x, y in iarea(area) do
			table.insert(newTiles, {name = tileName, position = {x, y}})
		end
	end
	surface.set_tiles(newTiles)
end

function chunkGen:removeEntities(surface,area)
	local ents = surface.find_entities(area)
	for i, entity in ipairs(ents) do
		--we should not remove the player for obvious reasons 
		if entity.type ~= "player" then
			entity.destroy()
		end
	end
end


	