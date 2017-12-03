local Animation = require 'src.Animation'
local Constants = require 'src.Constants'

local Title = {}

local sprites = {
    LOGO = love.graphics.newImage('res/img/logo.png'),
}

function Title:init()
    local font = love.graphics.newFont('res/font/redalert.ttf', 13)
    love.graphics.setFont(font)
end

function Title:enter()
    self.anim = Animation(sprites.LOGO, 3, 6)
end

function Title:update(dt)
    self.anim:update(dt)
end

function Title:draw()
    self.anim:draw(Constants.GAME_WIDTH / 2, Constants.GAME_HEIGHT / 2 - 16,
        0, 1, 1, 192 / 2, 120 / 2)
    love.graphics.printf('made in 2 days by @dvdfu for Ludum Dare 40',
        Constants.GAME_WIDTH / 2 - 128, Constants.GAME_HEIGHT / 2 + 40, 256, 'center')
end

return Title
