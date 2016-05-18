local class = require 'middleclass'
local Entity = require 'entity'
local Rat = class('Rat', Entity)

function Rat:spawnWithinArea(Room)
	local path = {
		p1 = {x = Room.x + 1, y = Room.y + 1},
		p2 = {x = Room.x + Room.width - 1, y = Room.y + 1},
		p3 = {x = Room.x + Room.width - 1, y = Room.y + Room.height - 1},
		p4 = {x = Room.x + 1, y = Room.y + Room.height - 1}
	}
	local rat = {
		x = path.p1.x,
		y = path.p1.y,
		width = 32,
		height = 32,
		other = {
			path = path
		}
	}
	return self:new(rat, false)
end

function Rat:updatePath(dt)
	local path = self.other.path
	if self.y <= path.p1.y then
		if self.x < path.p2.x then
			self.x = self.x + self.spd * dt 
			self.y = path.p1.y 
		elseif self.x >= path.p2.x then
			self.x = path.p2.x
			self.y = self.y + self.spd * dt
		end
	end
	if self.x >= path.p2.x then
		if self.y < path.p3.y then
			self.x = path.p2.x
			self.y = self.y + self.spd * dt
		elseif self.y >= path.p3.y then
			self.x = self.x - self.spd * dt
			self.y = path.p3.y
		end
	end
end

return Rat