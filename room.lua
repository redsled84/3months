local Range = require 'range'
local class = require 'middleclass'
local Room = class('Room')

function Room:initialize(widthRange, heightRange, tileSize, firstRoom, corridor)
	self.width = widthRange:Random()
	self.height = widthRange:Random()


	if firstRoom then
		local xOffset = math.random(-1, 1)
		local yOffset = math.random(-1, 1)
		self.x = math.floor(math.floor(love.graphics.getWidth() / tileSize) / 2 - self.width / 2) + xOffset
		self.y = math.floor(math.floor(love.graphics.getHeight() / tileSize) / 2 - self.height / 2) + yOffset
	else
		local xRange = Range:new(corridor.x - self.width + 2, corridor.x-2)
		local yRange = Range:new(corridor.y - self.height + 2, corridor.y-2)

		self.enteringCorridor = corridor.direction

		if self.enteringCorridor == 0 then
			self.x = xRange:Random()
			self.y = corridor.y - self.height
		elseif self.enteringCorridor == 1 then
			self.x = corridor.x+corridor.width
			self.y = yRange:Random()
		elseif self.enteringCorridor == 2 then
			self.x = xRange:Random()
			self.y = corridor.y + corridor.height
		elseif self.enteringCorridor == 3 then
			self.x = corridor.x - self.width
			self.y = yRange:Random()
		end
	end
end

return Room