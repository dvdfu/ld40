love.graphics.setLineStyle('rough')
love.graphics.setDefaultFilter('nearest', 'nearest')
love.mouse.setVisible(false)

math.randomseed(os.time())

local Constants = require 'src.Constants'
local Title = require 'src.states.Game'
local Gamestate = require 'modules.hump.gamestate'
local Vector = require 'modules.hump.vector'

local sprites = {
    CURSOR = love.graphics.newImage('res/img/cursor.png'),
    CURSOR_DRAG = love.graphics.newImage('res/img/cursor_drag.png'),
}

mousePosition = Vector()
mouseDown = false

function love.load()
    Gamestate.switch(Title)
end

function love.update(dt)
    dt = 1
    Gamestate.update(dt)
end

function love.draw()
    love.graphics.scale(Constants.SCREEN_SCALE, Constants.SCREEN_SCALE)
    Gamestate.draw()

    local x, y = mousePosition:unpack()
    if mouseDown then
        love.graphics.draw(sprites.CURSOR_DRAG, x, y, 0, 1, 1, 4, 1)
    else
        love.graphics.draw(sprites.CURSOR, x, y, 0, 1, 1, 4, 1)
    end
end

function love.mousepressed(x, y)
    mouseDown = true
    Gamestate.mousepressed(x / Constants.SCREEN_SCALE, y / Constants.SCREEN_SCALE)
end

function love.mousereleased(x, y)
    mouseDown = false
    Gamestate.mousereleased(x / Constants.SCREEN_SCALE, y / Constants.SCREEN_SCALE)
end

function love.mousemoved(x, y, dx, dy)
    local scale = Constants.SCREEN_SCALE
    mousePosition.x = x / scale
    mousePosition.y = y / scale
    Gamestate.mousemoved(x / scale, y / scale, dx / scale, dy / scale)
end
