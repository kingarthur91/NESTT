local geometry = {}

--make a triangle based on a point and vector
--point, the start point, 
--vector the direction and height of the triangle 
--width is the width of the triangle side opposed to point

local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local pi = math.pi

function geometry.addPos( p1, p2 )
	if p1.x then
		p1 = {p1.x,p1.y}
	end
	if p2.x then
		p2 = {p2.x,p2.y}
	end
	return {p1[1]+p2[1],p1[2]+p2[2]}
end

--subtract
function geometry.subPos( p1, p2 )
	if p1.x then
		p1 = {p1.x,p1.y}
	end
	if p2.x then
		p2 = {p2.x,p2.y}
	end
	return {p1[1]-p2[1],p1[2]-p2[2]}
end

function geometry.normalize(vec)
	if vec[1] == 0 and vec[2] == 0 then return end
	local mag = sqrt(vec[1] * vec[1] + vec[2] * vec[2])
	return {vec[1]/mag,vec[2]/mag}
end

function geometry.scale(vec,scale)
	return {vec[1]*scale,vec[2]*scale}
end


--counter clockwise rotation
function geometry.rotate(vec, theta)
	local c,s = cos(theta), sin(theta)
	return {vec[1]*c - vec[2]*s,vec[1]*s + vec[2]*c}
end

local addPos = geometry.addPos
local subPos = geometry.subPos
local normalize = geometry.normalize
local scale = geometry.scale

function geometry.makeTriangleFromPointVector( point, vector , width)
	local tri = {point}
	local pMid = addPos(point,vector)
	local vSideStep = normalize({-vector[2],vector[1]})
	vSideStep = scale(vSideStep, width/2)
	tri[2] = addPos(pMid,vSideStep)
	tri[3] = subPos(pMid,vSideStep)
	return tri
end

--returns a bounding box of the shape
function geometry.shapeBBox(verts)
	local x0, y0, x1, y1 = verts[1][1], verts[1][2], verts[1][1], verts[1][2]
	for i,v in ipairs(verts) do
		if v[1] < x0 then x0 = v[1]
		elseif v[1] > x1 then x1 = v[1]
		end
		if v[2] < y0 then y0 = v[2]
		elseif v[2] > y1 then y1 = v[2]
		end
	end
	return {{x0,y0},{x1,y1}}
end

function geometry.circleBBox(p,r)
	p = p.x and {p.x,p.y} or p
	return {{p[1]-r,p[2]-r},{p[1]+r,p[2]+r}}
end

--from http://stackoverflow.com/questions/2049582/how-to-determine-a-point-in-a-triangle
--returns the points in the triangle
function geometry.pointsInTriange(triangle,points)
	local p0, p1, p2 = triangle[1], triangle[2], triangle[3]
	local s1 = p0[2] * p2[1] - p0[1] * p2[2]
	local s2 = p2[2] - p0[2]
	local s3 = p0[1] - p2[1]
	local t1 = p0[1] * p1[2] - p0[2] * p1[1]
	local t2 = p0[2] - p1[2]
	local t3 = p1[1] - p0[1]
	local pointsIn = {}
	local A
	local Aabs
	for i,point in ipairs(points) do
		local p = point.position and {point.position.x,point.position.y} or point
		local s = s1 + s2 * p[1] + s3 * p[2]
		local t = t1 + t2 * p[1] + t3 * p[2]
		if not((s < 0) ~= (t < 0)) then
			if not A then
				A = -p1[2] * p2[1] + p0[2] * (p2[1] - p1[1]) + p0[1] * (p1[2] - p2[2]) + p1[1] * p2[2]
			end
			Aabs = A
			if (A < 0.0) then
				s = -s
				t = -t
				Aabs = -A
			end
			if s > 0 and t > 0 and (s + t) <= Aabs then 
				table.insert(pointsIn, point)
			end
		end
	end
	return pointsIn
end

--returns the points in the circle
function geometry.pointsInCircle(c,rSqr,points)
	local pointsIn = {}
	c = c.position and {c.position.x,c.position.y} or c
	for i,point in ipairs(points) do
		local p = point.position and {point.position.x,point.position.y} or point
		if ((p[1] - c[1]) * (p[1] - c[1]) + (p[2] - c[2]) * (p[2] - c[2])) < rSqr then
			table.insert(pointsIn, point)
		end
	end
	return pointsIn
end

--returns points that are on the same half plane of a vector
function geometry.isOnSameSideOfVector(vStart,vEnd,points)
	local pointsIn = {}
	vStart = vStart.position and {vStart.position.x,vStart.position.y} or vStart
	vEnd = vEnd.position and {vEnd.position.x,vEnd.position.y} or vEnd
	local v = geometry.subPos(vEnd,vStart)
	for i,point in ipairs(points) do
		local p = point.position and {point.position.x,point.position.y}
		local vp = subPos(p,vStart)
		--dot product
		if (v[1] * vp[1] + v[2] * vp[2]) > 0 then
			table.insert(pointsIn, point)
		end
	end
	return pointsIn
end

--returns points that are in semicircle, radiusPoint is a point on the circle pointing in the direction of the full part of the semicircle
function geometry.pointsInSemicircle(c,radiusPoint,points)
	local pointsIn = {}
	pointsIn = geometry.isOnSameSideOfVector(c,radiusPoint,points)
	local rSqr = subPos(radiusPoint,c)
	rSqr = rSqr[1] * rSqr[1] + rSqr[2] * rSqr[2]
	pointsIn = geometry.pointsInCircle(c,rSqr,pointsIn)
	return pointsIn
end
	
	
	
	
	
	
return geometry