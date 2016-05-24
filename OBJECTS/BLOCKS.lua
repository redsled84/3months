local Globals = require 'GLOBALS'
local world, tileSize = Globals.world, Globals.tileSize
local class = require 'libs.middleclass'

local BLOCKS = class('BLOCKS')


function BLOCKS:initialize(o, x, y, width, height)
	world:add(o, x, y, width, height)
end


function BLOCKS:initializeFromBoardMap(Board)
	for y = 0, #Board.map do
		for x = 0, #Board.map[y] do
			local num = Board.map[y][x]
			if num == 1 then
				local block = {
					x = (Board.x + x)*tileSize,
					y = (Board.y + y)*tileSize,
					width = tileSize,
					height = tileSize
				}
				BLOCKS:initialize(block, block.x, block.y, block.width, block.height)
			end
		end
	end
end


function BLOCKS:removeUnneccessaryBlocks(Rooms, Corridors)
	local items, len = world:getItems()

	for i = 1, len do
		local item = items[i]
		for j = 1, #Rooms do
			local room = Rooms[j]
			if (item.y + item.height + 1 > room.y) then
				world:remove(item)
				break
			end
		end
		-- for k = 1, #Corridors do
		-- 	local corridor = Corridors[k]
		-- 	if CheckSurrondings(item, corridor) then
		-- 		world:remove(item)
		-- 		break
		-- 	end
		-- end
	end
end


function BLOCKS:remove()
	local items, len = world:getItems()

	for i = 1, len do
		world:remove(items[i])
	end
end


function BLOCKS:draw()
	local items, len = world:getItems()
	for i = 1, len do
		love.graphics.setColor(255,255,255,100)
		love.graphics.rectangle('line', items[i].x, items[i].y, items[i].width, items[i].height)
	end
end


return BLOCKS