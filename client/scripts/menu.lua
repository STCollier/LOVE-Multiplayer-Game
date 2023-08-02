local utf8 = require("utf8")
local gamestate = require "scripts/gamestate"
local player = require "scripts/player"

local menu = {
	playerCount = 0,
	errMessage = "",
	gameIsReady = false,
	input = {
		username = "",
		hovered = false,
		clicked = false,
		focused = false,
		x = 0,
		y = love.graphics.getHeight() / 2,
		w = 500,
		h = 70
	},

	button = {
		color = 225,
		padding = 10,
		hovered = false,
		clicked = false,
		submitted = false,
		x = 0,
		y = love.graphics.getHeight() / 2,
		w = 150,
		h = 70,
		clickable = true,
	}
}

local rgb = love.math.colorFromBytes
local smallFont = love.graphics.newFont(30)
local uiFont = love.graphics.newFont(50)
local titleFont = love.graphics.newFont(85)

function hovered(px, py, rx, ry, rw, rh)
	return (px >= rx and px <= rx + rw and py >= ry and py <= ry + rh)
end

function menu:load()
	love.keyboard.setKeyRepeat(true)

	menu.input.x = (love.graphics.getWidth()/2 - menu.button.w/2) - menu.button.padding/2
	menu.button.x = (menu.input.x + menu.input.w/2) + (menu.button.w/2) + menu.button.padding

	client:on("connect", function(data)
		client:on("playerCount", function(data)
			menu.playerCount = data
		end)
    end)

    client:on("invalidUsername", function(data)
    	menu.input.username = ""
    	menu.errMessage = "Client already exists"
    	menu.button.clickable = true
    end)

    client:on("ready", function()
    	menu.gameIsReady = true
    end)
end

function menu:draw()
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.setFont(smallFont)
   	love.graphics.printf(menu.playerCount.." players online", 25, 25, 400, "left")

	love.graphics.setFont(titleFont)
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.printf("Game Title", love.graphics.getWidth()/2-love.graphics.getWidth()/4, 100, love.graphics.getWidth()/2, "center")

	love.graphics.setFont(uiFont)
	love.graphics.setColor(rgb(225, 225, 225))
	love.graphics.rectangle("fill", menu.input.x-menu.input.w/2, menu.input.y-menu.input.h/2, menu.input.w, menu.input.h, 10, 10)
	love.graphics.setColor(0, 0, 0, 1)


	love.graphics.setColor(rgb(0, 0, 0))
	love.graphics.printf(menu.input.username, menu.input.x-menu.input.w/2, (menu.input.y-menu.input.h/2)+5, menu.input.w, "center")


	if menu.input.focused then
		love.graphics.setColor(rgb(150, 150, 150))
		love.graphics.setLineWidth(3)
	else
		love.graphics.setColor(rgb(200, 200, 200))
		love.graphics.setLineWidth(2)
	end

	love.graphics.rectangle("line", menu.input.x-menu.input.w/2, menu.input.y-menu.input.h/2, menu.input.w, menu.input.h, 10, 10)

	--[[

	]]--

	love.graphics.setColor(rgb(menu.button.color, menu.button.color, menu.button.color))
	love.graphics.rectangle("fill", menu.button.x-menu.button.w/2, menu.button.y-menu.button.h/2, menu.button.w, menu.button.h, 10, 10)
	love.graphics.setColor(0, 0, 0, 1)


	love.graphics.setColor(rgb(0, 0, 0))
	love.graphics.printf("Play", menu.button.x-menu.button.w/2, (menu.button.y-menu.button.h/2)+5, menu.button.w, "center")


	if menu.button.hovered then
		love.graphics.setLineWidth(3)
		love.graphics.setColor(rgb(150, 150, 150))
		menu.button.color = 200
	else
		love.graphics.setLineWidth(2)
		love.graphics.setColor(rgb(200, 200, 200))
		menu.button.color = 225
	end

	love.graphics.rectangle("line", menu.button.x-menu.button.w/2, menu.button.y-menu.button.h/2, menu.button.w, menu.button.h, 10, 10)

	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.setFont(smallFont)
   	love.graphics.printf(menu.errMessage, (menu.input.x-menu.input.w/2)+10, menu.input.y-menu.input.h/4, menu.input.w, "center")
end

function menu:update(client)
	local x, y = love.mouse.getPosition()

	menu.input.clicked = love.mouse.isDown(1)
	menu.input.hovered = hovered(x, y, menu.input.x-menu.input.w/2, menu.input.y-menu.input.h/2, menu.input.w, menu.input.h)

	menu.button.clicked = love.mouse.isDown(1)
	menu.button.hovered = hovered(x, y, menu.button.x-menu.button.w/2, menu.button.y-menu.button.h/2, menu.button.w, menu.button.h)
	menu.button.submitted = (((menu.button.clicked and menu.button.hovered) or love.keyboard.isDown("return")) and string.len(menu.input.username) > 0) and menu.button.clickable

	if (((menu.button.clicked and menu.button.hovered) or love.keyboard.isDown("return"))) and string.len(menu.input.username) == 0 then
		menu.errMessage = "Please enter a username"
	end


	if (menu.input.clicked and menu.input.hovered) then
		menu.input.focused = true
	elseif (not menu.input.hovered and menu.input.clicked) then
		menu.input.focused = false
	end

    if (menu.button.submitted) then
    	client:send("player", menu.input.username)
    	menu.button.clickable = false
    end 

    if (menu.gameIsReady) then
    	player:init(menu.input.username, world) -- DONT UPDATE MULTIPLE TIMES
    	gamestate.scene = "game"
    end
end

function love.textinput(t)
    if string.len(menu.input.username) < 10 and menu.input.focused then 
    	menu.errMessage = ""
    	menu.input.username = menu.input.username .. t
    end
end

function love.keypressed(key)
    if key == "backspace" and menu.input.focused then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(menu.input.username, -1)

        if byteoffset then
            menu.input.username = string.sub(menu.input.username, 1, byteoffset - 1)
        end
    end
end

return menu