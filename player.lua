local class = require 'middleclass'
local util = require 'util'
local Globals = require 'globals'

local tileSize, world = Globals.tileSize, Globals.world

local Player = class('Player')

function Player:initialize(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.vx = 0
	self.vy = 0
	self.xThreshold = 60
	self.yThreshold = 60
	self.spd = 900
	self.topVel = 750
	self.triggered = true

	world:add(self, x, y, width, height)
end

local function collisionFilter(item, other)

end

function Player:collision(dt)
	local actualX, actualY, cols, len = world:move(self, self.x, self.y) -- collisionFilter would be last arg
	for i=len, 1, -1 do
		local v = cols[i]
		if v.normal.x == -1 then 
			self.x = v.other.x - self.width
			self.vx = 0
		end
		if v.normal.x == 1 then
			self.x = v.other.x + v.other.width
			self.vx = 0
		end
		if v.normal.y == -1 then
			self.y = v.other.y - self.height
			self.vy = 0
		end
		if v.normal.y == 1 then
			self.y = v.other.y + v.other.height
			self.vy = 0
		end
	end
end

function Player:joystickMovement(dt, joystick)
	self.vx = self.vx + joystick:getGamepadAxis('leftx') * 12
	self.vy = self.vy + joystick:getGamepadAxis('lefty') * 12
	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt
end

function Player:keyboardMovement(dt)
	if love.keyboard.isDown('d') and self.vx < self.topVel then
		self.vx = self.vx + self.spd * dt
	elseif love.keyboard.isDown('a') and self.vx > -self.topVel then
		self.vx = self.vx - self.spd * dt
	elseif self.vx > self.xThreshold then
	    self.vx = self.vx - self.spd * dt
	elseif self.vx < -self.xThreshold then
		self.vx = self.vx + self.spd * dt
	elseif self.vx < self.xThreshold and self.vx > -self.xThreshold then
		self.vx = 0
	end
	if love.keyboard.isDown('w') and self.vy > -self.topVel then
		self.vy = self.vy - self.spd * dt
	elseif love.keyboard.isDown('s') and self.vy < self.topVel then
		self.vy = self.vy + self.spd * dt
	elseif self.vy > self.yThreshold then
		self.vy = self.vy - self.spd * dt
	elseif self.vy < -self.yThreshold then
		self.vy = self.vy + self.spd * dt
	elseif self.vy < self.yThreshold and self.vy > -self.yThreshold then
		self.vy = 0
	end

	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt
end

function Player:update(dt, joystick)
	if joystick ~= nil and love.joystick.getJoystickCount() > 0 then
		self:joystickMovement(dt, joystick)
	else
		self:keyboardMovement(dt)
	end
	self:collision(dt)
	world:update(self, self.x, self.y)
end

local timer = 0
function Player:triggerSomeFuckingEvent(dt, lastRoom, f)
	if Player.x + Player.width > lastRoom.x*tileSize and
	Player.x < (lastRoom.x + lastRoom.width)*tileSize and
	Player.y + Player.height > lastRoom.y*tileSize and
	Player.y < (lastRoom.y + lastRoom.height)*tileSize then
		timer = timer + dt
		if timer >= 1 then
			f()
			timer = 0
		end
	end
end

function Player:draw()
	local g = love.graphics
	g.setColor(0,255,255,200)
	g.rectangle('fill', self.x, self.y, self.width, self.height)
end

return Player