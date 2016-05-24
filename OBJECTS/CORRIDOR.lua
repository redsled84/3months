local Range = require 'OBJECTS.RANGE'
local class = require 'libs.middleclass'
local CORRIDOR = class('CORRIDOR')


function CORRIDOR:initialize(room, lengthRange, firstCorridor)
	-- 0 = North, 1 = East, 2 = South, 3 = West
	self.direction = math.random(0, 3)

	if not firstCorridor then
		local oppositeDirection = (room.enteringCorridor + 2) % 4
		if oppositeDirection == self.direction then
			-- Turn 90 degrees clockwise
			self.direction = (self.direction + 1) % 4
		end
	end

	local length = lengthRange:Random()

	if self.direction == 0 then
		self.x = math.random(room.x+2, room.x + room.width - 2)
		self.y = room.y - length
		self.width = 2
		self.height = length
	end
	if self.direction == 1 then
		self.x = room.x + room.width
		self.y = math.random(room.y+2, room.y + room.height - 2)
		self.width = length
		self.height = 2
	end
	if self.direction == 2 then
		self.x = math.random(room.x+2, room.x + room.width - 2)
		self.y = room.y + room.height
		self.width = 2
		self.height = length
	end
	if self.direction == 3 then
		self.x = room.x - length
		self.y = math.random(room.y+2, room.y + room.height - 2)
		self.width = length
		self.height = 2
	end
end


return CORRIDOR