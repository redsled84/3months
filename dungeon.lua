local Corridor = require 'corridor'
local Globals = require 'globals'
local Range = require 'range'
local Room = require 'room'
local Rat = require 'rat'
local class = require 'middleclass'
local util = require 'util'

local tileSize = Globals.tileSize

local Dungeon = class('Dungeon')
Dungeon.Rooms, Dungeon.Corridors = {}, {}
Dungeon.Mobs, Dungeon.Items = {}, {}


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
	util.DeleteTableElements(self.Mobs)
end

function Dungeon:createStructure()
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
	end

	if #self.Corridors >= #self.Rooms then
		table.remove(self.Corridors, #self.Corridors)
	end

	-- added for testing purposes
	self.lastRoom = self.Rooms[#self.Rooms]
end

function Dungeon:getRandomRoom()
	local roomRange = Range:new(2, #self.Rooms)
	local i = roomRange:Random()
	return self.Rooms[i]
end

-- replace corridors of certain length with rooms
function Dungeon:replaceCorridorsWithRooms()
	local lengthLimit = 6
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
end

function Dungeon:spawnMobs()
	local mobRange = Range:new(5, 8)
	local maxMobsInRoom = 2

	for i = 1, mobRange:Random() do
		local randomRoom = self:getRandomRoom()
		-- if randomRoom.mobs < maxMobsInRoom then
			-- replace this table entry with adding a new mob from mob class
			local xRange = Range:new(1, randomRoom.width-1)
			local yRange = Range:new(1, randomRoom.height-1)

			table.insert(self.Mobs, {
				x = (randomRoom.x + xRange:Random()),
				y = (randomRoom.y + yRange:Random()),
				width = tileSize,
				height = tileSize
			})
		-- end
	end
end

function Dungeon:spawnItems()
	local itemRange = Range:new(2, 5)

	for i = 1, itemRange:Random() do
		local randomRoom = self:getRandomRoom()

		local xRange = Range:new(1, randomRoom.width-1)
		local yRange = Range:new(1, randomRoom.height-1)
		
		table.insert(self.Items, {
			x = randomRoom.x + xRange:Random(),
			y = randomRoom.y + yRange:Random(),
			width = tileSize,
			height = tileSize
		})
	end
end

function Dungeon:initialize(intersections, minIntersections, maxIntersections)
	self:createStructure()
	self:replaceCorridorsWithRooms()
	self:spawnMobs()
	self:spawnItems()

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

	for i, mob in ipairs(self.Mobs) do
		g.setColor(0,255,0,255)
		g.rectangle('fill', mob.x*tileSize, mob.y*tileSize, mob.width, mob.height)
	end

	for i, item in ipairs(self.Items) do
		g.setColor(255,255,0,100)
		g.rectangle('fill', item.x*tileSize, item.y*tileSize, item.width, item.height)
	end
end

return Dungeon