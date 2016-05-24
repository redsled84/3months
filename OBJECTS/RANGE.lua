local class = require 'libs.middleclass'
local RANGE = class('RANGE')

function RANGE:initialize(min, max)
	self.min, self.max = min, max
end

function RANGE:Random()
	return math.random(self.min, self.max)
end

return RANGE