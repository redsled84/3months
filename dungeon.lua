local Corridor = require 'corridor'
local Globals = require 'globals'
local Range = require 'range'
local Room = require 'room'
local Rat = require 'rat'
local class = require 'middleclass'
local util = require 'util'

local tileSize = Globals.tileSize

local Dungeon = class('Dungeon'); Dungeon.Rooms, Dungeon.Corridors = {}, {}
Dungeon.creatures = {}

function Dungeon:checkOverlappingRooms()
	local amount = 0
	local duplicate = util.Duplicate(self.Rooms)
	for i=#self.Rooms, 1, -1 do
		table.remove(duplicate, i)

		for j=#duplicate, 1, -1 do
			if util.AABB(self.Rooms[i], duplicate[j]) then
				amount = amount + 1
			end
		end

		for k=#self.Corridors, 1, -1 do
			if util.AABB(self.Rooms[i], self.Corridors[k]) then
				amount = amount + 1
			end
		end

		duplicate = util.Duplicate(self.Rooms)
	end
	return amount / 2
end

function Dungeon:remove()
	util.DeleteTableElements(self.Rooms)
	util.DeleteTableElements(self.Corridors)
end

function Dungeon:initialize(intersections, minIntersections, maxIntersections)
	local nRooms = Range:new(5, 12)
	local widthRange = Range:new(9, 16)	
	local heightRange = Range:new(9, 16)
	local lengthRange = Range:new(5, 18)
	local lengthLimit = 6
	
	self.Rooms[1] = Room:new(widthRange, heightRange, tileSize, true)
	self.Corridors[1] = Corridor:new(self.Rooms[1], lengthRange, true)
	
	for i = 2, nRooms:Random() do
		self.Rooms[i] = Room:new(widthRange, heightRange, tileSize, false, self.Corridors[i-1])
		self.Corridors[i] = Corridor:new(self.Rooms[i], lengthRange, false)

		if self.Rooms[i].width > 7 and self.Rooms[i].height > 7 then
			self.creatures[#self.creatures+1] = Rat:spawnWithinArea(self.Rooms[i])
		end
	end

	self.lastRoom = self.Rooms[#self.Rooms]
	
	if #self.Corridors >= #self.Rooms then
		table.remove(self.Corridors, #self.Corridors)
	end

	for i = #self.Corridors, 1, -1 do
		local c = self.Corridors[i]
		if c.direction == 1 or c.direction == 3 and c.width < lengthLimit then
			local heightRange = Range:new(5, 8)
			self.Rooms[#self.Rooms+1] = {
				x = c.x,
				y = c.y-2,
				width = c.width,
				height = heightRange:Random()
			}
			table.remove(self.Corridors, i)
		elseif c.direction == 0 or c.direction == 2 and c.height < lengthLimit then
			local widthRange = Range:new(5, 8)
			self.Rooms[#self.Rooms+1] = {
				x = c.x-2,
				y = c.y,
				width = widthRange:Random(),
				height = c.height
			}
			table.remove(self.Corridors, i)
		end
	end

	if intersections then 
		if self:checkOverlappingRooms() < minIntersections or 
		self:checkOverlappingRooms() > maxIntersections then
			self:remove()
			self:initialize(intersections, minIntersections, maxIntersections)
		end
	elseif self:checkOverlappingRooms() ~= 0 then
		self:remove()
		self:initialize(intersections, minIntersections, maxIntersections)
	end
end

function Dungeon:draw()
	local g = love.graphics

	for i, room in ipairs(self.Rooms) do
		g.setColor(255,255,255,30)
		g.rectangle('fill', room.x*tileSize, room.y*tileSize, 
			room.width*tileSize, room.height*tileSize)
		g.setColor(0,0,255,230)
		g.rectangle('line', room.x*tileSize, room.y*tileSize, 
			room.width*tileSize, room.height*tileSize)
		g.setColor(255,255,255)
		g.print(tostring(i) .. ' ' .. tostring(room.x*tileSize), room.x*tileSize, room.y*tileSize)
	end

	for i, corridor in ipairs(self.Corridors) do
		g.setColor(0,0,255,100)
		g.rectangle('fill', corridor.x*tileSize, corridor.y*tileSize,
			corridor.width*tileSize, corridor.height*tileSize)
		g.setColor(0,0,255,230)
		g.rectangle('line', corridor.x*tileSize, corridor.y*tileSize,
			corridor.width*tileSize, corridor.height*tileSize)
	end

	for i, creature in ipairs(self.creatures) do
		g.setColor(0,255,0,255)
		g.rectangle('fill', creature.x*tileSize, creature.y*tileSize, creature.width, creature.height)
	end
end

return Dungeon