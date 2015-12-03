require "lib"
bboxShapes = {}

local function shallowCopy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end


--direction must be -1 or 1 
function bboxShapes.trapezoid(startLine,stepCount,direction,stepSize)
	local bboxes = {}
	startLine = simplifyBbox(startLine)
	local currentBox = startLine
	stepSize = stepSize or 1
	for i = 1, stepCount do
		table.insert(bboxes,currentBox)
		currentBox = {
			{
				currentBox[1][1]-stepSize,
				currentBox[1][2]+direction
			},
			{
				currentBox[2][1]+stepSize,
				currentBox[2][2]+direction
			}
		}
	end
	return bboxes
end