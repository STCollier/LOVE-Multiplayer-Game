local sock = require "lib/sock"

local players = {} -- Player list (storing client table, num players)
local allClients = {} -- Client list (storing positions and actual game data)

t = 0

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function table.removekey(table, key)
   local element = table[key]
   table[key] = nil
   return element
end

-- server.lua
function love.load()
    -- Creating a server on any IP, port 22122
    server = sock.newServer("localhost", 8080)

    server:on("connect", function(data, client)
        client:send("playerCount", tablelength(players))
    end)

    server:on("player", function(data, client)
        if (tablelength(players) > 0) then
            for k, v in pairs(players) do
                if (string.lower(v) ~= string.lower(data)) then
                    players[client] = data
                    client:send("joinGame", {
                        username = data,
                        numPlayers = tablelength(players),
                    })
                    client:send("ready")
                    print(data.." connected to the game")
                else
                    client:send("invalidUsername")
                end
            end
        else
            players[client] = data
            client:send("joinGame", {
                username = data,
                numPlayers = 1,
            })
            client:send("ready")
            print(data.." connected to the game")
        end
    end)

    server:on("disconnect", function(data, client)
        table.removekey(players, client)
        client:send("leaveGame", tablelength(players))
    end)

    server:on("playerPosition", function(data, client)
        print(data.username, data.x, data.y)
        allClients[data.username] = {
            username = data.username,
            x = data.x,
            y = data.y
        }

        client:send("playerData", allClients)
    end)
end

function love.update(dt)
    server:update()
end