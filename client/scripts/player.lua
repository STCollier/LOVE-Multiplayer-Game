local map = require "scripts/map"
local anim8 = require "lib/anim8"

local player = {
	x = 0,
	y = 0,
	r = 50,
	velX = 0,
	velY = 0,
	jumps = 0,
	killed = false,
	username = nil,
	physics = {
		body = nil,
		shape = nil,
		fixture = nil
	},
	spritesheet = nil,
	animations = {},
	anim = nil
}

t = 0

function player:init(username, world)
	local nametagFont = love.graphics.newFont(30)
	love.graphics.setFont(nametagFont)

	self.x = map.spawn.x
	self.y = map.spawn.y

	self.username = username

	self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic")
	self.physics.shape = love.physics.newCircleShape(self.r)
	self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
	self.physics.body:setFixedRotation(true)
    self.physics.body:setMass(1.2)
    self.physics.fixture:setUserData("Player")

    self.spritesheet = love.graphics.newImage("sprites/slime_anim_horizontal.png")
    local animGrid = anim8.newGrid(20, 21, self.spritesheet:getWidth(), self.spritesheet:getHeight())

    self.animations.jump = anim8.newAnimation(animGrid('1-11', 1), 0.1)
    self.anim = self.animations.jump

end

function player:update(client, dt)
	--self.anim:update(dt)

	self.velX, self.velY = self.physics.body:getLinearVelocity()

    if love.keyboard.isDown("right") and self.velX < 400 then
        self.physics.body:applyForce(500, 0)
    elseif love.keyboard.isDown("left") and self.velX > -400 then
        self.physics.body:applyForce(-500, 0)
    end

    if love.keyboard.isDown("up") and self.jumps > 0 then
    	self.physics.body:applyLinearImpulse(0, -500)
        self.jumps = self.jumps - 1
    end

    camera:lookAt(self.physics.body:getX(), self.physics.body:getY())

    t = t + dt
    if t >= 0.016 then
    	t = 0
    	client:send("playerPosition", {
			username = self.username,
			x = self.physics.body:getX(),
			y = self.physics.body:getY(),
		})
    end

    if (self.killed) then
    	player.physics.body:setPosition(map.spawn.x, map.spawn.y)
    	self.killed = false
	end
end

function player:draw()
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.printf(self.username, self.physics.body:getX() - 250, self.physics.body:getY() - 75*1.5, 500, "center")

	love.graphics.setColor(0.28, 0.63, 0.05)
  	love.graphics.circle("fill", self.physics.body:getX(), self.physics.body:getY(), self.physics.shape:getRadius())
	--[[love.graphics.setColor(1, 1, 1)
	self.anim:draw(self.spritesheet, self.physics.body:getX()-self.r, self.physics.body:getY()-self.r, nil, map.scale, map.scale)]]--
end

function player:handleCollisions(a, b)
    if a:getUserData() == "Player" and b:getUserData() == "Solids" or a:getUserData() == "Solids" and b:getUserData() == "Player" then
        self.jumps = 1
    end

    if a:getUserData() == "Player" and b:getUserData() == "Kill Zone" or a:getUserData() == "Kill Zone" and b:getUserData() == "Player" then
		self.killed = true
    end
end

return player