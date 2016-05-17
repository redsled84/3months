local util = {}
util.timer = 0

function util.Duplicate(t)
	local t2 = {}
	for k=1, #t do
		t2[k] = t[k]
	end
	return t2
end

function util.AABB(a, b)
	if a.x + a.width > b.x and
	a.x < b.x + b.width and
	a.y + a.height > b.y and
	a.y < b.y + b.height then
		return true
	end
end

function util.AABP(p1, p2, o)
	if p1 >= o.x and
	p1 < o.x + o.width and
	p2 >= o.y and
	p2 < o.y + o.height then
		return true
	end
end

function util.DeleteTableElements(t)
	for k=#t, 1, -1 do
		table.remove(t, k)
	end
end

function util.approach(sVel, accel, goal)
	local dir = (sVel - goal > sVel) and -1 or (sVel - goal < sVel and 1 or (sVel > 0 and -1 or 1))
	if (dir > 0 and sVel + accel > goal) or (dir < 0 and sVel - accel < goal) then
		return goal
	end
	sVel = sVel + dir * accel
	return sVel
end

function util.print(str, interval, dt)
	util.timer = util.timer + dt
	if util.timer > interval then
		print(str)
		util.timer = 0
	end
end

return util