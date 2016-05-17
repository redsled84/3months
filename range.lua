local class = require 'middleclass'
local Range = class('Range')

function Range:initialize(min, max)
	self.min, self.max = min, max
end

function Range:Random()
	return math.random(self.min, self.max)
end

return Range