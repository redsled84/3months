local util = require 'util'
local GLOBALS = require 'GLOBALS'
local tileSize, world = GLOBALS.tileSize, GLOBALS.world

local BOARD = require 'OBJECTS.BOARD'
local BLOCKS = require 'OBJECTS.BLOCKS'
local CAMERA = require 'libs.camera'
local DUNGEON = require 'OBJECTS.DUNGEON'
local PLAYER = require 'MOBS.PLAYER'

local GAME = {}


function GAME.load()
	if DUNGEON.rooms ~= nil and DUNGEON.corridors ~= nil then
		DUNGEON:remove()
		BOARD:remove()
		BLOCKS:remove()
	end

	DUNGEON:initialize(false)
	local rooms, corridors = DUNGEON.rooms, DUNGEON.corridors
	BOARD:initialize(rooms, corridors)
	BLOCKS:initializeFromBoardMap(BOARD)
	local fRoom = rooms[1]
	PLAYER:initialize(fRoom.x*tileSize+1, fRoom.y*tileSize+1, tileSize, tileSize)
	camera = CAMERA.new(PLAYER.x, PLAYER.y, .75)
end


function GAME.update(dt)
	camera:lookAt(PLAYER.x, PLAYER.y)

	PLAYER:update(dt, Joystick)
	local lastRoom = DUNGEON.lastRoom
	PLAYER:triggerSomeFuckingEvent(dt, lastRoom, function()
		GAME.load()
	end)
end


function GAME.draw()
	camera:attach()
		DUNGEON:draw()
		PLAYER:draw()
	camera:detach()
end


return GAME