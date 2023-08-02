local sock = require "lib/sock"

local menu = require "scripts/menu"
local gamestate = require "scripts/gamestate"
local player = require "scripts/player"
local map = require "scripts/map"
local cam = require "lib/camera"
local projectile = require "scripts/projectile"

local allPlayers = {}

function drawPlayer(name, x, y)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf(name, x - 250, y - 75*1.5, 500, "center")

    love.graphics.setColor(0.28, 0.63, 0.05)
    love.graphics.circle("fill", x, y, 50)
end

-- client.lua
function love.load()
    love.graphics.setBackgroundColor(1, 1, 1, 1)

    camera = cam()

    client = sock.newClient("localhost", 8080)

    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81*64, true)
    world:setCallbacks(beginContact)

    love.graphics.setDefaultFilter("nearest", "nearest")

    menu:load()
    map:load()

    player:init("Player", world)

    projectile:spawn("bomb", map.spawn.x-500, map.spawn.y-500)

    client:on("disconnect", function(data)
        client:on("leaveGame", function(data)
            gamestate.numPlayers = data.numPlayers
        end)
    end)

    client:on("joinGame", function(data)
        print(data.username.." joined")
        gamestate.numPlayers = data.numPlayers
    end)

    client:on("playerData", function(data)
        allPlayers = data
    end)

    client:connect()
end

function love.update(dt)
    client:update()
    
    if (gamestate.scene == "menu") then menu:update(client) end
    if (gamestate.scene == "game") then
        world:update(dt)
        player:update(client, dt)
        map:update()

        if not projectile.destroyed then projectile:update(dt) end

        --[[for key, v in pairs(allPlayers) do
            print(allPlayers[key].username, allPlayers[key].x, allPlayers[key].y)
        end]]--
    end
end

function love.draw()
    if (gamestate.scene == "menu") then menu:draw() end
    if (gamestate.scene == "game") then
        camera:attach()
        for key, v in pairs(allPlayers) do
            if (allPlayers[key].username ~= menu.input.username) then
                drawPlayer(allPlayers[key].username, allPlayers[key].x, allPlayers[key].y)
            else
                player:draw()
            end
        end

        if not projectile.destroyed then projectile:draw() end

        love.graphics.setColor(1, 1, 1, 1)
        map:draw()
        camera:detach()
    end
end 


function beginContact(a, b) 
    player:handleCollisions(a, b) 
end