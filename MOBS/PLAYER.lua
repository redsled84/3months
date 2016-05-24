local GLOBALS = require 'GLOBALS'
local tileSize, world = GLOBALS.tileSize, GLOBALS.world
local class = require 'libs.middleclass'
local util = require 'util'

local PLAYER = class('PLAYER')


function PLAYER:initialize(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.vx = 0
	self.vy = 0
	self.xThreshold = 5
	self.yThreshold = 5
	self.spd = 1500
	self.decSpd = 600
	self.topVel = 600
	self.triggered = true

	world:add(self, x, y, width, height)
end


local function collisionFilter(item, other)

end


function PLAYER:collision(dt)
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


function PLAYER:joystickMovement(dt, joystick)
	self.vx = self.vx + joystick:getGamepadAxis('leftx') * 12
	self.vy = self.vy + joystick:getGamepadAxis('lefty') * 12
	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt
end


function PLAYER:keyboardMovement(dt)
	if love.keyboard.isDown('d') and self.vx < self.topVel then
		self.vx = self.vx + self.spd * dt
	end
	if love.keyboard.isDown('a') and self.vx > -self.topVel then
		self.vx = self.vx - self.spd * dt
	end
	if self.vx > 0 then
		self.vx = self.vx - self.decSpd * dt
	elseif self.vx < 0 then
		self.vx = self.vx + self.decSpd * dt
	end
	if -self.xThreshold <= self.vx and self.vx <= self.xThreshold then
		self.vx = 0
	elseif self.vx >= self.topVel then
		self.vx = self.topVel
	elseif self.vx <= -self.topVel then
		self.vx = -self.topVel
	end

	if love.keyboard.isDown('w') then
		self.vy = self.vy - self.spd * dt
	end
	if love.keyboard.isDown('s') then
		self.vy = self.vy + self.spd * dt
	end
	if self.vy > 0 then
		self.vy = self.vy - self.decSpd * dt
	elseif self.vy < 0 then
		self.vy = self.vy + self.decSpd * dt
	end
	if -self.yThreshold <= self.vy and self.vy <= self.yThreshold then
		self.vy = 0
	elseif self.vy >= self.topVel then
		self.vy = self.topVel
	elseif self.vy <= -self.topVel then
		self.vy = -self.topVel
	end

	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt
end


function PLAYER:update(dt, joystick)
	if joystick ~= nil and love.joystick.getJoystickCount() > 0 then
		self:joystickMovement(dt, joystick)
	else
		self:keyboardMovement(dt)
	end
	self:collision(dt)
	world:update(self, self.x, self.y)
end


local timer = 0
function PLAYER:triggerSomeFuckingEvent(dt, lastRoom, f)
	if PLAYER.x + PLAYER.width > lastRoom.x*tileSize and
	PLAYER.x < (lastRoom.x + lastRoom.width)*tileSize and
	PLAYER.y + PLAYER.height > lastRoom.y*tileSize and
	PLAYER.y < (lastRoom.y + lastRoom.height)*tileSize then
		timer = timer + dt
		if timer >= 1 then
			f()
			timer = 0
		end
	end
end


function PLAYER:draw()
	local g = love.graphics
	g.setColor(0,255,255,200)
	g.rectangle('fill', self.x, self.y, self.width, self.height)
end


return PLAYER