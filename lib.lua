function copyPrototype(type, name, newName)
  local p = table.deepcopy(data.raw[type][name])
  p.name = newName
  if p.minable and p.minable.result then
    p.minable.result = newName
  end
  return p
end

function simplifyBbox(bbox)
	local b = {{},{}}
	local t = {}
	t[1] = bbox[1] or bbox.left_top or bbox.lefttop
	t[2] = bbox[2] or bbox.right_bottom or bbox.rightbottom
	b[1][1] = t[1][1] or t[1].x
	b[1][2] = t[1][2] or t[1].y
	b[2][1] = t[2][1] or t[2].x
	b[2][2] = t[2][2] or t[2].y
	return b
end

--This trims the area so that it is not inclusive of the bottom right x and y values
function areaTrim(area)
	local bbox = simplifyBbox(area)
	bbox[2][1] = bbox[2][1] - 1
	bbox[2][2] = bbox[2][2] - 1
	return bbox
end
--iarea this was taken from the Homeworld mod helpers/helpers.lua and modified
--https://github.com/perky/factorio-homeworld/
function iarea( area )
	simplifyBbox(area)
	local aa = area[1]
	local bb = area[2]
	local _ax = aa[1]
	local _ay = aa[2]
	local reachedEnd = false
	return function()
		if reachedEnd then return nil end
		local x = _ax
		local y = _ay
		_ax = _ax + 1
		if _ax > bb[1] then
			_ax = aa[1]
			_ay = _ay + 1
			if _ay > bb[2] then
				reachedEnd = true
			end
		end
		return x, y
	end
end

