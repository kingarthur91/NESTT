require "chunkGen"


nesttChunkGen = chunkGen:new()


function nesttChunkGen:generate(surface,area)
	local tileName = "out-of-map"
	self:removeEntities(surface,area)
	self:setTiles(surface,area,tileName)
	
end

function nesttChunkGen:LocomoTilesGen(surface)
	self:setTilesMultiArea(surface, nesttConfig.entityData.locomotive.tileAreas(),"train-floor")
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

function nesttChunkGen:WagonTilesGen(surface)
	self:setTilesMultiArea(surface, nesttConfig.entityData.locomotive.tileAreas())
end