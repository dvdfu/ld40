love.graphics.setLineStyle('rough')
love.graphics.setDefaultFilter('nearest', 'nearest')
love.mouse.setVisible(false)

math.randomseed(os.time())

local Constants = require 'src.Constants'
local Title = require 'src.states.Title'
local Gamestate = require 'modules.hump.gamestate'
local Sprites = require 'src.Sprites'
local Vector = require 'modules.hump.vector'

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
        love.graphics.draw(Sprites.ui.CURSOR_DRAG, x, y, 0, 1, 1, 4, 1)
    else
        love.graphics.draw(Sprites.ui.CURSOR, x, y, 0, 1, 1, 4, 1)
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
