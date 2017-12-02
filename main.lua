love.graphics.setLineStyle('rough')
love.graphics.setDefaultFilter('nearest', 'nearest')
love.mouse.setVisible(false)

math.randomseed(os.time())

local Constants = require 'src.Constants'
local Game = require 'src.states.Game'
local Gamestate = require 'modules.hump.gamestate'

local SCALE = 4

function love.load()
    Gamestate.switch(Game)
end

function love.update(dt)
    dt = 1
    Gamestate.update(dt)
end

function love.draw()
    love.graphics.scale(Constants.SCREEN_SCALE, Constants.SCREEN_SCALE)
    Gamestate.draw()
end

function love.mousepressed(x, y)
    Gamestate.mousepressed(x / Constants.SCREEN_SCALE, y / Constants.SCREEN_SCALE)
end

function love.mousereleased(x, y)
    Gamestate.mousereleased(x / Constants.SCREEN_SCALE, y / Constants.SCREEN_SCALE)
end

function love.mousemoved(x, y, dx, dy)
    Gamestate.mousemoved(x / SCALE, y / SCALE, dx / SCALE, dy / SCALE)
end
