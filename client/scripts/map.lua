local sti = require "lib/sti"

local map = {
	scale = 7,
	spawn = {
		x = nil,
		y = nil,
	}
}

function map:load()
 	_map = sti("maps/map.lua")
    
    self.width = (_map.width * _map.tilewidth) * self.scale
    self.height = (_map.height * _map.tileheight) * self.scale

    local solids = {}
	if (_map.layers["Solids"]) then
		for i, obj in pairs(_map.layers["Solids"].objects) do
			solids.body = love.physics.newBody(world, (obj.x+obj.width/2)*self.scale, (obj.y+obj.height/2)*self.scale, "static")
			solids.shape = love.physics.newRectangleShape(obj.width*self.scale, obj.height*self.scale)
			solids.fixture = love.physics.newFixture(solids.body, solids.shape)
			solids.fixture:setUserData("Solids")
		end
	end

    local killZones = {}
	if (_map.layers["Kill Zones"]) then
		for i, obj in pairs(_map.layers["Kill Zones"].objects) do
			killZones.body = love.physics.newBody(world, (obj.x+obj.width/2)*self.scale, (obj.y+obj.height/2)*self.scale, "static")
			killZones.shape = love.physics.newRectangleShape(obj.width*self.scale, obj.height*self.scale)
			killZones.fixture = love.physics.newFixture(killZones.body, killZones.shape)
			killZones.fixture:setUserData("Kill Zone")
		end
	end

	if (_map.layers["Spawn"]) then
		for i, obj in pairs(_map.layers["Spawn"].objects) do
			map.spawn.x = (obj.x+obj.width/2)*self.scale
			map.spawn.y = (obj.y+obj.height/2)*self.scale
		end
	end


end

function map:update()
	if camera.x < love.graphics.getWidth()/2 then
        camera.x = love.graphics.getWidth()/2
    end
    if camera.y < love.graphics.getHeight()/2 then
        camera.y = love.graphics.getHeight()/2
    end

    if camera.x > (self.width - love.graphics.getWidth()/2) then
        camera.x = (self.width - love.graphics.getWidth()/2)
    end
    if camera.y > (self.height - love.graphics.getHeight()/2)/2 + 100 then
        camera.y = (self.height - love.graphics.getHeight()/2)/2 + 100
    end
end

function map:draw()
	love.graphics.push()
	love.graphics.scale(map.scale)
	_map:drawImageLayer("Map")
	love.graphics.pop()
end

return map