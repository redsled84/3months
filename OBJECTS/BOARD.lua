local GLOBALS = require 'GLOBALS'
local class = require 'libs.middleclass'
local util = require 'util'

local tileSize = GLOBALS.tileSize

local BOARD = class('BOARD')

local function compareXAndWidth(a, b) return a.x+a.width < b.x+b.width end
local function compareYAndHeight(a, b) return a.y+a.height < b.y+b.height end
local function compareX(a, b) return a.x < b.x end
local function compareY(a, b) return a.y < b.y end

function BOARD:initialize(rooms, corridors)
	local firstX = {}
	local firstY = {}
	local sortedX = {}
	local sortedY = {}
	
	for i=#rooms, 1, -1 do
		table.insert(sortedX, rooms[i])
		table.insert(sortedY, rooms[i])
		table.insert(firstX, rooms[i])
		table.insert(firstY, rooms[i])
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
			
			for i = 1, #rooms do
				if util.AABP(checkX, checkY, rooms[i]) then 
					self.map[y][x] = 0
				end
			end
			
			for i = 1, #corridors do
				if util.AABP(checkX, checkY, corridors[i]) then
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

function BOARD:remove()
	util.DeleteTableElements(self.map)
end

return BOARD