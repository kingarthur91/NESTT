local geometry = require "libs/geometry"
local nesttChunkGen = require "nesttChunkGen"

local nesttMiner = {}

function nesttMiner:new(surface)
	miner = {}
	miner.surfaceTable = nesttSurface:getSurfaceTable(surface)
	self.__index = self
	global.nesttMiners = global.nesttMiners or {validIndex = 1}
	local namePrefix = "miner_"
	local name
	local validIndex = global.nesttMiners.validIndex
	repeat
		name = namePrefix .. validIndex
		validIndex = validIndex + 1
	until not global.nesttMiners[name]
	global.nesttMiners.validIndex = validIndex
	global.nesttMiners[name] = miner
	miner.name = name
	setmetatable(miner, self)
	global.onTickFunctions[name] = miner
	return miner
end

function nesttMiner:delete()
	global.onTickFunctions[self.name] = nil
	global.nesttMiners[self.name] = nil
end

--call this on_load and on_init
function nesttMiner:init()
	if not global.nesttMiners then return end
	self.__index = self
	for k,miner in pairs(global.nesttMiners) do
		if type(miner) == "table" then 
			setmetatable(miner, self)
		end
	end
end

-- try to insert a single item to the chests
function nesttMiner:tryInsertItem(itemStack)
	local data = self.surfaceTable.surfaceData
	local oreChestSettings = nesttConfig.entityData.oreChest
	local maxStack = oreChestSettings.masterMaxStackPerItem
	local masterChest = data.masterChest
	local oreChests = data.oreChests
	local masterCache = data.masterCache
	local name = itemStack.name
	local count = itemStack.count
	local excess
	--try to put into masterChest
	if (masterCache[name] and masterCache[name] < maxStack) or (not masterCache[name]) then
		masterCache[name] = masterCache[name] or 0
		local freeSpace = maxStack - masterCache[name]
		local toInsert = math.min(freeSpace,count)
		excess = count - toInsert
		
		itemStack.count = toInsert
		if masterChest.insert(itemStack) == 0 then
			masterCache[name] = masterCache[name] + toInsert
		else
			excess = count
		end
	end
	
	if excess == 0 then return nil end
	if not excess then excess = count end
	itemStack.count = excess
	--try to put into oreChests
	if oreChests[name] then 
		excess = excess - oreChests[name].insert(itemStack)
	end
	if excess == 0 then return nil end
	itemStack.count = excess
	
	return itemStack
end


--[[
.prototype.mineable_properties.products.type == "item"
.prototype.mineable_properties.products.name
--]]

local function addToTank(tankEnt, name, amount)
	if not tankEnt then return false end
	local fluidbox = tankEnt.fluidbox
	if fluidbox[1] and fluidbox[1].type ~= name then return false end
	local prevAmount = fluidbox[1] and fluidbox[1].amount or 0
	if prevAmount + amount > 2500 then return false end
	
	fluidbox[1] = {type = name,amount = prevAmount + amount}
	return true
end

local function getResYield(res)
	local prototype = res.prototype
	if not prototype.infinite_resource then return 1 end
	local min = res.prototype.minimum_resource_amount
	local max = min * 10
	local current = res.amount
	return current / max
end

--try to mine the resource and put it into chest
function nesttMiner:tryMineResources(resources)
	local data = self.surfaceTable.surfaceData
	for _,res in pairs(resources) do
		if res.name == "water" then
			addToTank(data.waterTank,"water",30)
		elseif res.name == "crude-oil" then 
			local yield = getResYield(res)
			if addToTank(data.oilTank,"crude-oil",yield*30) then
				res.amount = math.max(res.amount - yield*30,res.prototype.minimum_resource_amount)
			end
		elseif res.name == "item-on-ground" then 
			local stack = res.stack
			local excess = self:tryInsertItem(stack)
			if not excess then
				res.destroy()
			end
		elseif res.prototype.mineable_properties.minable
			and res.prototype.mineable_properties.products[1].type == "item" then
			local mineCount = res.prototype.mineable_properties.products[1].amount_max
			local name = res.prototype.mineable_properties.products[1].name
			local stack = {name = name,count = mineCount}
			local excess = self:tryInsertItem(stack)
			if not excess then excess = {count = 0} end
			if excess.count == mineCount then return end
			if res.type == "resource" then
				if res.amount - mineCount + excess.count <= 0 then 
					res.destroy()
				else
					res.amount = res.amount - mineCount + excess.count
				end
			else 
				res.destroy()
			end
		end
	end
end


--data should point to a global table
function nesttMiner:refreshOreChests()
	local data = self.surfaceTable.surfaceData
	local trainSurface = self.surfaceTable.surface
	local oreChestSettings = nesttConfig.entityData.oreChest
	data.oreChests = {}
	local bbox = oreChestSettings.bBoxL
	local oreChests = trainSurface.find_entities_filtered{area = bbox, type= "container"}
	bbox = oreChestSettings.bBoxR
	oreChests2 = trainSurface.find_entities_filtered{area = bbox, type= "container"}
	for k,v in pairs(oreChests2) do
		table.insert(oreChests,v)
	end
	
	for k,v in pairs(oreChests) do
		--t = oreChests.get_inventory().get_contents()
		local offset = v.position.x < 0 and -1 or 1
		local templateChest = trainSurface.find_entity(
			oreChestSettings.templateChestName,  
			{v.position.x + offset, v.position.y})
		if templateChest then
			local inv = templateChest.get_inventory(1).get_contents()
			local name,_ = next(inv, nil)
			if name then data.oreChests[name] = v end
		end
	end
	
	--find and save master chest
	if not data.masterChest then 
		local masterChestSettings = nesttConfig.entityData.locomotive.entityGen.masterChest
		local pos = masterChestSettings.create.position
		local name = masterChestSettings.create.name
		data.masterChest = trainSurface.find_entity(name, pos)
	end
	
	--this is probably expensive to call for each item so we cache it
	data.masterCache = data.masterChest.get_inventory(1).get_contents()
	
	--find and save oil/water tanks
	local water = nesttConfig.entityData.locomotive.entityGen.waterTank
	data.waterTank = trainSurface.find_entity(water.create.name, water.create.position)
	
	local oil = nesttConfig.entityData.locomotive.entityGen.oilTank
	data.oilTank = trainSurface.find_entity(oil.create.name, oil.create.position)
	
	--get the train extentionChest
	if not data.extentionChest then 
		local chestData = nesttConfig.entityData.locomotive.entityGen.extentionChest
		data.extentionChest = trainSurface.find_entity(chestData.create.name, chestData.create.position)
	end
end

local function makeTriangle(train, width, height, headOffset)
	local theta = train.orientation * math.pi * 2
	local dirVec = geometry.rotate({0,-height}, theta)
	local startPoint = train.position
	headOffset = geometry.rotate(headOffset, theta)
	startPoint = geometry.addPos(startPoint,headOffset)
	return geometry.makeTriangleFromPointVector( startPoint, dirVec , width)
end

function nesttMiner:addWagon(wagon) 
	local data = self.surfaceTable.surfaceData
	local trainEnt = self.surfaceTable.entity
	local outSurf = trainEnt.surface
	local train = trainEnt.train
	local lastSeg = train.carriages[#train.carriages]
	local offsetVec = {1,5.2 +0.01} --the length of trains segments is 4.8 - 5.2
	local offsetVec2 = {-1,5.2 +0.01}
	local theta = lastSeg.orientation * math.pi * 2
	offsetVec = geometry.rotate(offsetVec, theta)
	offsetVec2 = geometry.rotate(offsetVec2, theta)
	if #train.carriages > 30 then  return false end
	
	if data.lastDeletedWagonPos then
		if geometry.distanceSq(data.lastDeletedWagonPos, trainEnt.position) < 36 then return false end
		data.lastDeletedWagonPos = nil
	end
	if #train.carriages > 1 then
		local secondLastSeg = train.carriages[#train.carriages - 1]
		local backwardsVec = geometry.subPos(lastSeg.position, secondLastSeg.position)
		--flip orientation if it is wrong (dot product < 0)
		if geometry.dot(offsetVec,backwardsVec) < 0 then
			offsetVec = {-offsetVec[1],-offsetVec[2]}
		end
		if geometry.dot(offsetVec2,backwardsVec) < 0 then
			offsetVec2 = {-offsetVec2[1],-offsetVec2[2]}
		end
	end
	local newPosition = geometry.addPos(lastSeg.position,offsetVec)
	local newPosition2 = geometry.addPos(lastSeg.position,offsetVec2)
	if not outSurf.can_place_entity{name = wagon.name, position = newPosition} then
		newPosition = newPosition2 
		if not outSurf.can_place_entity{name = wagon.name, position = newPosition} then 
			data.lastDeletedWagonPos = trainEnt.position
			return false 
		end
	end
	local newWagon = outSurf.create_entity{name = wagon.name, position = newPosition}
	if not newWagon or not newWagon.train then 
		data.lastDeletedWagonPos = trainEnt.position
		return false 
	end
	--if the wagon was added, but not connected or wrong connection
	if trainEnt.train.carriages[#trainEnt.train.carriages] ~= newWagon then 
		newWagon.destroy()
		data.lastDeletedWagonPos = trainEnt.position
		return false 
	end
	return true
end

--called every tick
function nesttMiner:onTick()
	--print(self.name .. " onTick")
	local data = self.surfaceTable.surfaceData
	local train = self.surfaceTable.entity
	local trainSurface = self.surfaceTable.surface
	local worldSurface = train.surface
	local beamSettings = nesttConfig.entityData.miningBeam
	--calculate train head offset and train orientation
	local radius,headOffset = beamSettings.radius, beamSettings.headOffset
	local theta = train.orientation * math.pi * 2
	headOffset = geometry.rotate(headOffset, theta)
	local beamStartPoint = geometry.addPos(train.position,headOffset)
	--make train head invis entity
	if not data.headHelperEnt then 
		data.headHelperEnt = worldSurface.create_entity{name = beamSettings.helperEntity, position = beamStartPoint} 
	else 
		data.headHelperEnt.teleport(beamStartPoint)
	end
	--get beams that are still in range
	local rVec = geometry.rotate({0,-radius}, theta)
	rVec = geometry.addPos(beamStartPoint,rVec)
	local rVecL = geometry.rotate({0,-radius - 1}, theta)
	rVecL = geometry.addPos(beamStartPoint,rVecL)
	data.beamHelperEnt = data.beamHelperEnt or {}
	local inRangeBeamHelpers, outRangeBeamHelpers = geometry.pointsInSemicircle(beamStartPoint,rVecL,data.beamHelperEnt)
	--each tick there is a random chance that one of the beams will change position
	if #inRangeBeamHelpers ~= 0 and math.random() < 0.1 then
		local index = math.random(#inRangeBeamHelpers)
		local change = table.remove(inRangeBeamHelpers,index)
		table.insert(outRangeBeamHelpers,change)
	end
	--check area for resources, save these
	local bbox = geometry.circleBBox(beamStartPoint,radius)
	local res = worldSurface.find_entities_filtered{area = bbox, type= "resource"}
	--trees
	local trees = worldSurface.find_entities_filtered{area = bbox, type= "tree"}
	
	for _,tree in pairs(trees) do
		table.insert(res,tree)
	end
	--filter the ores using semi circle
	res = geometry.pointsInSemicircle(beamStartPoint,rVec,res)
	--check area for water tiles, save these
	local tilePos = geometry.bBoxToTilePos(bbox)
	tilePos = geometry.pointsInSemicircle(beamStartPoint,rVec,tilePos)
	for _, p in pairs(tilePos) do
		if worldSurface.get_tile(p[1],p[2]).name == "water" then
			table.insert(res,{name = "water",position = {p[1],p[2]}})
		end
	end
	--destroy all beams and return if #res is 0
	if not res or #res == 0 then
		destroyEntityTable(data.beamHelperEnt)
	else
	--get resources that are full and filter them
	--pick random resource patches at least one per resource type, unless full (not fully implemented)
		local randIndices = {}
		local numOfAvailableBeams = math.min(beamSettings.count - #inRangeBeamHelpers, #res)
		for i = 1, numOfAvailableBeams do
			randIndices[i] = math.random(#res)
		end
		--remove the out of range entities
		destroyEntityTable(outRangeBeamHelpers)
		--reset the global table
		data.beamHelperEnt = {}
		--make graphical beam entity
		for i = 1, numOfAvailableBeams do
			data.beamHelperEnt[i] = worldSurface.create_entity{
				name = beamSettings.helperEntity, 
				position = beamStartPoint}
			worldSurface.create_entity{
				name = beamSettings.name, 
				position = {0,0},
				source = data.headHelperEnt,
				target = data.beamHelperEnt[i]}
			local randI = randIndices[i]
			local randOff = {math.random()-0.5,math.random()-0.5}
			data.beamHelperEnt[i].teleport(geometry.addPos(res[randI].position,randOff))
		end
		--add the inRangeBeamsBack
		for i,v in ipairs(inRangeBeamHelpers) do
			table.insert(data.beamHelperEnt,v)
		end
		
		--refresh oreChests
		self:refreshOreChests()
		--harvest the resources
		local resList = {}
		for i = 1, beamSettings.miningPower do
			randIndices[i] = math.random(#res)
			local randI = randIndices[i]
			local ore = res[randI]
			table.insert(resList,ore)
		end
		self:tryMineResources(resList)
	end
	--add wagons
	local wagonName = nesttConfig.entityData.wagon.name
	if data.extentionChest then 
		local inv = data.extentionChest.get_inventory(1)
		if inv.get_item_count(wagonName) ~= 0 then
			if self:addWagon({name = wagonName}) then
			--create wagon tiles
				inv.remove{name = wagonName, count = 1}
			end
		end
	end
	--gen wagon tiles
	if not data.wagonsGenerated then data.wagonsGenerated = 0 end
	local wagonCount = 0
	for _,v in pairs(train.train.carriages) do
		if v.name == wagonName then
			wagonCount = wagonCount + 1
		end
	end
	if wagonCount > data.wagonsGenerated then 
		if nesttChunkGen:wagonTilesGen(trainSurface,data.wagonsGenerated) then 
			data.wagonsGenerated = data.wagonsGenerated+1
		end
	end
	
	--set train speed
	if not data.speed then data.speed = {setSpeed = 0, playerChangedSpeed = false} end
	local playerControl = false
	if train.passenger then 
		if train.passenger.riding_state.acceleration ~= defines.riding.acceleration.nothing then
			playerControl = true
			data.speed.playerChangedSpeed = true
		end
	end
	if not playerControl then
		if data.speed.playerChangedSpeed == true then
			data.speed.setSpeed = train.train.speed
			data.speed.playerChangedSpeed = false
		end
		train.train.speed = data.speed.setSpeed

	end
	
	--self heal
	train.health = train.health + 0.05 
end



--/c p(game.player.selected.prototype.mineable_properties)
--[[
{
	minable = true,
	hardness = 1,
	miningtime = 1,
	products = {
		[1] = {
			type = "fluid"/item,
			name = crude-oil,
			amount_min = 1,
			amount_max = 1,
			probability = 1}

	crude-oil:
	infinite = true,
    minimum = 750,
    normal = 7500, --1/s

--]]


return nesttMiner