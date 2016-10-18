require "chunkGen"


local nesttChunkGen = chunkGen:new()


function nesttChunkGen:generate(surface,area)
	local tileName = "out-of-map"
	self:removeEntities(surface,area)
	self:setTiles(surface,area,tileName)
	
end

function nesttChunkGen:LocomoTilesGen(surface)
	self:setTilesMultiArea(surface, nesttConfig.entityData.locomotive.tileAreas())
end

function nesttChunkGen:LocomoEntityGen(surface)
	 local entityGen = nesttConfig.entityData.locomotive.entityGen
	 local data = nesttSurface:getSurfaceTable(surface).surfaceData
	 data.savedEntities = data.savedEntities or {}
	 for k,v in pairs(entityGen) do
		local ent = surface.create_entity(v.create)
		if v.destructible ~= nil then ent.destructible = v.destructible end
		if v.minable ~= nil then ent.minable = v.minable end
		if v.insert then ent.insert(v.insert) end
		ent.force = game.forces.player
		if type(k) == "string" then
			data.savedEntities[k] = ent --save the named entities for later use
		end
	end
	--print(data)
end

function nesttChunkGen:wagonTilesGen(surface,wagonsGenerated)
	local offset = wagonsGenerated * nesttConfig.entityData.wagon.height
		+ nesttConfig.entityData.locomotive.height
	
	local chunkY = (offset - nesttConfig.entityData.wagon.height / 2 + 0.5) / 32
	chunkY = math.floor(chunkY)
	local hasUnGenChunk
	for i = 0,2 do
		if not surface.is_chunk_generated{-1,i+chunkY} then
			hasUnGenChunk = true
		end
		if not surface.is_chunk_generated{0,i+chunkY} then
			hasUnGenChunk = true
		end
	end
	if hasUnGenChunk then return false end
	self:setTilesMultiArea(surface, nesttConfig.entityData.wagon.tileAreas(offset))
	return true
end

return nesttChunkGen