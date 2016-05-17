local util = require 'util'
local Camera = require 'camera'
local Inspect = require 'inspect'
local Dungeon = require 'dungeon'
local Globals = require 'globals'
local tileSize = Globals.tileSize
local world = Globals.world
local Rooms, Corridors = Dungeon.Rooms, Dungeon.Corridors
local Board = require 'board'
local Blocks = require 'blocks'
local Player = require 'player'

local Joystick = nil
local timer = 0

local function ResetWorld()
	Dungeon:remove()
	Board:remove()
	Blocks:remove()
	Dungeon:initialize(false)
	Board:initialize(Rooms, Corridors)
	Blocks:initializeFromBoardMap(Board)
	Player:initialize(Rooms[1].x*tileSize, Rooms[1].y*tileSize, tileSize, tileSize)
end

math.randomseed(os.time())
math.random();math.random();math.random();

function love.load()
	Dungeon:initialize(false)
	Board:initialize(Rooms, Corridors)
	Blocks:initializeFromBoardMap(Board)
	-- Blocks:removeUnneccessaryBlocks(Rooms, Corridors)
	Player:initialize(Rooms[1].x*tileSize+1, Rooms[1].y*tileSize+1, tileSize, tileSize)
	camera = Camera.new(Player.x, Player.y, .5)
end

function love.joystickadded(joystick)
	Joystick = joystick
end

function love.joystickremoved(joystick)
	Joystick = joystick
end

function love.update(dt)
	camera:lookAt(Player.x, Player.y)

	Player:update(dt, Joystick)
	local lastRoom = Dungeon.lastRoom
	Player:triggerSomeFuckingEvent(dt, lastRoom, function()
		ResetWorld()
	end)

	util.print(love.joystick.getJoystickCount(), 10, dt)
end

function love.draw()
	camera:attach()
		Dungeon:draw()
		Player:draw()
	camera:detach()
end

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
	if key == 'r' then
		ResetWorld()
	end
end