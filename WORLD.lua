local class = require 'libs.middleclass'
local WORLD = class('WORLD')

function WORLD:initialize(f)
	f()
end

function WORLD:update(f, dt)
	f(dt)
end

function WORLD:draw(f)
	f()
end

return WORLD