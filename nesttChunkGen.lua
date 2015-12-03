require "chunkGen"
nesttChunkGen = chunkGen:new()



function nesttChunkGen:generate(surface,area)
	local tileName = "train-floor"
	self:removeEntities(surface,area)
	self:setTiles(surface,area,tileName)
end

function nesttChunkGen:HeadTilesGen(surface)
	self:setTilesMultiArea(surface, nesttConfig.entityData.locomotive.tileAreas())
end

function nesttChunkGen:HeadTilesGen(surface)
	self:setTilesMultiArea(surface, nesttConfig.entityData.locomotive.tileAreas())
end