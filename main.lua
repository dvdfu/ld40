love.graphics.setLineStyle('rough')
love.graphics.setDefaultFilter('nearest', 'nearest')

math.randomseed(os.time())

local Gamestate = require 'modules.hump.gamestate'
local Game = require 'src.states.Game'

local SCALE = 4

function love.load()
    Gamestate.switch(Game)
end

function love.update(dt)
    dt = 1
    Gamestate.update(dt)
end

function love.draw()
    love.graphics.scale(SCALE, SCALE)
    Gamestate.draw()
end

function love.mousepressed(x, y)
    Gamestate.mousepressed(x / SCALE, y / SCALE)
end

function love.mousereleased(x, y)
    Gamestate.mousereleased(x / SCALE, y / SCALE)
end

function love.mousemoved(x, y)
    Gamestate.mousemoved(x / SCALE, y / SCALE)
end
