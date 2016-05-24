local GLOBALS = require 'GLOBALS'
local class = require 'libs.middleclass'
local RANGE = require 'OBJECTS.RANGE'
local util = require 'util'
local CORRIDOR = require 'OBJECTS.CORRIDOR'
local ROOM = require 'OBJECTS.ROOM'

local tileSize = GLOBALS.tileSize

local DUNGEON = class('DUNGEON')


function DUNGEON:initialize(intersections, minIntersections, maxIntersections)
	self.rooms, self.corridors = {}, {}
	self:createStructure()
	self:replaceCorridorsWithRooms()

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


function DUNGEON:createStructure()
	local nRooms = RANGE:new(5, 12)
	local widthRange = RANGE:new(9, 16)	
	local heightRange = RANGE:new(9, 16)
	local lengthRange = RANGE:new(5, 18)
	local lengthLimit = 6
	
	self.rooms[1] = ROOM:new(widthRange, heightRange, tileSize, true)
	self.corridors[1] = CORRIDOR:new(self.rooms[1], lengthRange, true)
	
	for i = 2, nRooms:Random() do
		self.rooms[i] = ROOM:new(widthRange, heightRange, tileSize, false, self.corridors[i-1])
		self.corridors[i] = CORRIDOR:new(self.rooms[i], lengthRange, false)
	end

	if #self.corridors >= #self.rooms then
		table.remove(self.corridors, #self.corridors)
	end

	-- added for testing purposes
	self.lastRoom = self.rooms[#self.rooms]
end


-- replace corridors of certain length with rooms
function DUNGEON:replaceCorridorsWithRooms()
	local lengthLimit = 6
	for i = #self.corridors, 1, -1 do
		local c = self.corridors[i]
		if c.direction == 1 or c.direction == 3 and c.width < lengthLimit then
			local heightRange = RANGE:new(5, 8)
			self.rooms[#self.rooms+1] = {
				x = c.x,
				y = c.y-2,
				width = c.width,
				height = heightRange:Random()
			}
			table.remove(self.corridors, i)
		elseif c.direction == 0 or c.direction == 2 and c.height < lengthLimit then
			local widthRange = RANGE:new(5, 8)
			self.rooms[#self.rooms+1] = {
				x = c.x-2,
				y = c.y,
				width = widthRange:Random(),
				height = c.height
			}
			table.remove(self.corridors, i)
		end
	end
end


function DUNGEON:checkOverlappingRooms()
	local amount = 0
	local duplicate = util.Duplicate(self.rooms)
	for i=#self.rooms, 1, -1 do
		table.remove(duplicate, i)

		for j=#duplicate, 1, -1 do
			if util.AABB(self.rooms[i], duplicate[j]) then
				amount = amount + 1
			end
		end

		for k=#self.corridors, 1, -1 do
			if util.AABB(self.rooms[i], self.corridors[k]) then
				amount = amount + 1
			end
		end

		duplicate = util.Duplicate(self.rooms)
	end
	return amount / 2
end


function DUNGEON:remove()
	util.DeleteTableElements(self.rooms)
	util.DeleteTableElements(self.corridors)
end


function DUNGEON:draw()
	local g = love.graphics

	for i, room in ipairs(self.rooms) do
		g.setColor(255,255,255,30)
		g.rectangle('fill', room.x*tileSize, room.y*tileSize, 
			room.width*tileSize, room.height*tileSize)
		g.setColor(0,0,255,230)
		g.rectangle('line', room.x*tileSize, room.y*tileSize, 
			room.width*tileSize, room.height*tileSize)
		g.setColor(255,255,255)
		g.print(tostring(i) .. ' ' .. tostring(room.x*tileSize), room.x*tileSize, room.y*tileSize)
	end

	for i, corridor in ipairs(self.corridors) do
		g.setColor(0,0,255,100)
		g.rectangle('fill', corridor.x*tileSize, corridor.y*tileSize,
			corridor.width*tileSize, corridor.height*tileSize)
		g.setColor(0,0,255,230)
		g.rectangle('line', corridor.x*tileSize, corridor.y*tileSize,
			corridor.width*tileSize, corridor.height*tileSize)
	end
end


function DUNGEON:getRandomRoom()
	local roomRange = RANGE:new(2, #self.rooms)
	local i = roomRange:Random()
	return self.rooms[i]
end


return DUNGEON