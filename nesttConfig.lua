require "bboxShapes"

nesttConfig = {
--surfaceSize can be nil for unlimited size
--TODO: make the tileGen and entityGen
entityData = {

	locomotive = {
		name = "nestt-locomotive", 
		mapGenSettings = {
			width = 32, 
			height = nil,
			water = "none",
			autoplace_controls = {frequency = "none"},
			},
		width = 16,
		height = 48,
		tileAreas = function()
			local width = 16
			local height = 48
			local headWidth = 4
			local tileName = "train-floor"
			
			local shape = {}
			local stepCount = (width - headWidth)/2
			local startLine = {
				{-headWidth/2,-height/2},
				{headWidth/2-1,-height/2}}
			local trape = bboxShapes.trapezoid(startLine,stepCount,1,1)
			for i,box in ipairs(trape) do
				table.insert(shape,box)
			end
			local square = {
			{-width/2,-height/2+stepCount},
			{width/2-1,height/2-1}}
			table.insert(shape,square)
				return shape, tileName
		end,
			
		entityGen = {
			templatesChest = {   
			--resource templates chest
				create = {
					name = "steel-chest",
					position = {-6.5,-18.5},
				},
				destructible = false,
				minable = false
			},
			fuelChest = {	
			--train fuel chest
				create = {
					name = "iron-chest",
					position = {6.5,-18.5},
				},
				destructible = false,
				minable = false
			},
			{	--fuel inserter
				create = {
					name = "burner-inserter",
					position = {6.5,-17.5},
					direction = 4,
				},
				
			},
			{	--coal chest
				create = {
				name = "iron-chest",
				position = {6.5,-16.5},
				},
			},
			{	--coal tamplate
				create = {
					name = "wooden-chest",
					position = {7.5,-16.5},
				},
				insert = {
					--coal tamplate insert
					name = "coal",
					count = 1,
				},
			},
		}
	}, 
	
	wagon = {
		name = "nestt-wagon",
	
	},
	
	miningBeam = {
		name = "mining-beam",
		helperEntity = "invisible-chest",
		width = 30,
		height = 15,
		headOffset = {0,-3},
		count = 7,
		
	},
},

surfacePrefix = "nestt_",
}

--Global
locomotive = nesttConfig.entityData.locomotive
wagon = nesttConfig.entityData.wagon