local util = require 'util'
local class = require 'middleclass'
local Globals = require 'globals'

local tileSize = Globals.tileSize

local Board = class('Board')

local function compareXAndWidth(a, b) return a.x+a.width < b.x+b.width end
local function compareYAndHeight(a, b) return a.y+a.height < b.y+b.height end
local function compareX(a, b) return a.x < b.x end
local function compareY(a, b) return a.y < b.y end

function Board:initialize(Rooms, Corridors)
	local firstX = {}
	local firstY = {}
	local sortedX = {}
	local sortedY = {}
	
	for i=#Rooms, 1, -1 do
		table.insert(sortedX, Rooms[i])
		table.insert(sortedY, Rooms[i])
		table.insert(firstX, Rooms[i])
		table.insert(firstY, Rooms[i])
		table.sort(sortedX, compareXAndWidth)
		table.sort(sortedY, compareYAndHeight)
		table.sort(firstX, compareX)
		table.sort(firstY, compareY)
	end
	
	self.x = firstX[1].x-1
	self.y = firstY[1].y-1
	self.width = (sortedX[#sortedX].x + sortedX[#sortedX].width - firstX[1].x)+1
	self.height = (sortedY[#sortedY].y + sortedY[#sortedY].height - firstY[1].y)+1
	self.map = {}

	for y = 0, self.height do
		self.map[y] = {}
		
		for x = 0, self.width do
			self.map[y][x] = 1

			local checkX = x + self.x
			local checkY = y + self.y
			
			for i = 1, #Rooms do
				if util.AABP(checkX, checkY, Rooms[i]) then 
					self.map[y][x] = 0
				end
			end
			
			for i = 1, #Corridors do
				if util.AABP(checkX, checkY, Corridors[i]) then
					self.map[y][x] = 0
				end
			end
		end
	end
	
	util.DeleteTableElements(sortedX)
	util.DeleteTableElements(sortedY)
	util.DeleteTableElements(firstX)
	util.DeleteTableElements(firstY)
end

function Board:remove()
	util.DeleteTableElements(self.map)
end

return Board