local Globals = require 'globals'
local tileSize, world = Globals.tileSize, Globals.world

local util = require 'util'
local class = require 'middleclass'

local Entity = class('Entity')

function Entity:initialize(o, addToWorld)
	self.x = o.x
	self.y = o.y
	self.width = o.width
	self.height = o.height
	self.spd = 4
	self.other = o.other
	if addToWorld then
		world:add(self, self.x, self.y, self.width, self.height)
	end
end

function Entity:update(entity, dx, dy)
	world:update(entity, dx, dy)
end

return Entity