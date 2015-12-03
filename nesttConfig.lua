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
			for i,box in trape do
				table.insert(shape,box)
			end
			local square = {
			{-width/2,-height/2+stepCount},
			{width/2-1,-height/2-1}}
			table.insert(shape,square)
				return shape, tileName
		end,
			
			entityGen = function()
				return {}
			end,
	}, 
	
	wagon = {
		name = "nestt-wagon",
	
	},
},

surfacePrefix = "nestt_",
}

--Global
locomotive = nesttConfig.entityData.locomotive
wagon = nesttConfig.entityData.wagon