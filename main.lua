math.randomseed(os.time())
math.random();math.random();math.random();

local WORLD = require 'WORLD'
local GAME = require 'SCENES.GAME'

function love.load()
	WORLD:initialize(GAME.load)
end

function love.update(dt)
	WORLD:update(GAME.update, dt)
end

function love.draw()
	WORLD:draw(GAME.draw)
end

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end