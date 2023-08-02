local projectile = {
	destroyed = false,
	physics = {}
}
local t = 0
allProjectiles = {}

function projectile:init()
	if self.type == "bomb" then
		self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic")
		self.physics.shape = love.physics.newCircleShape(25)
		self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
		self.physics.body:setFixedRotation(false)
	    self.physics.body:setMass(1)
	    self.physics.fixture:setRestitution(0.5)
	    self.physics.fixture:setUserData("Bomb")

	    self.timer = 3
	end
end

function projectile:spawn(type, x, y)
	self.x = x
	self.y = y

	self.type = type
	projectile:init()
end

function projectile:destroy()
	self.physics.body:destroy()
	if self.type == "bomb" then end
end

function projectile:update(dt) 
	if self.type == "bomb" then end


	t = t + dt
    if t >= 1 and self.timer > 0 then
    	t = 0
    	self.timer = self.timer - 1
    end

    if self.timer == 0 then 
    	projectile:destroy()
    	self.destroyed = true
    end

end

function projectile:draw()
	if (self.type == "bomb") then
		love.graphics.setColor(0, 0, 0)
  		love.graphics.circle("fill", self.physics.body:getX(), self.physics.body:getY(), self.physics.shape:getRadius())
  	end
end

return projectile 