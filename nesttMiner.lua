local geometry = require "libs/geometry"

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


local function makeTriangle(train, width, height, headOffset)
	local theta = train.orientation * math.pi * 2
	local dirVec = geometry.rotate({0,-height}, theta)
	local startPoint = train.position
	headOffset = geometry.rotate(headOffset, theta)
	startPoint = geometry.addPos(startPoint,headOffset)
	return geometry.makeTriangleFromPointVector( startPoint, dirVec , width)
end



	

--called every tick
function nesttMiner:onTick()
	--print(self.name .. " onTick")
	local data = self.surfaceTable.surfaceData
	local train = self.surfaceTable.entity
	local trainSurface = self.surfaceTable.surface
	local outSurface = train.surface
	local settings = nesttConfig.entityData.miningBeam

	--make triangle area in front of train
	local width,height,headOffset = settings.width, settings.height, settings.headOffset
	local tri = makeTriangle(train, width, height, headOffset)
	--make train head invis entity
	if not data.headHelperEnt then 
		data.headHelperEnt = outSurface.create_entity{name = settings.helperEntity, position = tri[1]} 
	else 
		data.headHelperEnt.teleport(tri[1])
	end
	--make bounding box from tri
	local bbox = geometry.shapeBBox(tri)
	--check area for resources, save these
	local res = outSurface.find_entities_filtered{area = bbox, type= "resource"}
	res = geometry.pointsInTriange(tri,res)
	--local check for out of range 
	--pick random resource patches at least one per resource type, unless full (not fully implemented)
	
	--get resources that are full and filter them
	local rand = math.random
	local randIndex = {}
	for i = 1, settings.count do
		randIndex = math.random(#res)
	end
	
	--make graphical beam entity
	data.beams = data.beams or {}
	data.beamHelperEnt = data.beamHelperEnt or {}
	for i = 1, settings.count do
		data.beamHelperEnt[i] = data.beamHelperEnt[i] or outSurface.create_entity{name = settings.helperEntity, position = tri[1]}
		data.beams[i] = data.beams[i] or outSurface.create_entity{
			name = settings.name, 
			position = {0,0},
			source = data.headHelperEnt,
			target = data.beamHelperEnt[i],
			}
		if res[i] then
			data.beamHelperEnt[i].teleport(res[i].position)
			if res[i].amount == 1 then res[i].destroy()
			else
				res[i].amount = res[i].amount - 1
			end
		end
		
	end
	
	
	--harvest the resources
		--train chest check
	
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
		}
	
	}
	


--]]








return nesttMiner