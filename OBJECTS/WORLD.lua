local GLOBALS = require 'GLOBALS'
local tileSize, world = GLOBALS.tileSize, GLOBALS.world
local class = require 'libs.middleclass'
local CAMERA = require 'libs.camera'
local util = require 'util'

local BOARD = require 'OBJECTS.BOARD'
local BLOCKS = require 'OBJECTS.BLOCKS'
local DUNGEON = require 'OBJECTS.DUNGEON'
local PLAYER = require 'MOBS.PLAYER'

local WORLD = class('WORLD')


function WORLD:initializeStartWorld()
	if DUNGEON.rooms ~= nil and DUNGEON.corridors ~= nil then
		DUNGEON:remove()
		BOARD:remove()
		BLOCKS:remove()
	end

	DUNGEON:initialize(false)
	local rooms, corridors = DUNGEON.rooms, DUNGEON.corridors
	BOARD:initialize(rooms, corridors)
	BLOCKS:initializeFromBoardMap(BOARD)
	PLAYER:initialize(rooms[1].x*tileSize+1, rooms[1].y*tileSize+1, tileSize, tileSize)
	camera = CAMERA.new(PLAYER.x, PLAYER.y, .75)
end


function WORLD:updateStartWorld(dt)
	camera:lookAt(PLAYER.x, PLAYER.y)

	PLAYER:update(dt, Joystick)
	local lastRoom = DUNGEON.lastRoom
	PLAYER:triggerSomeFuckingEvent(dt, lastRoom, function()
		self:initializeStartWorld()
	end)
end


function WORLD:drawStartWorld()
	camera:attach()
		DUNGEON:draw()
		PLAYER:draw()
	camera:detach()
end


return WORLD