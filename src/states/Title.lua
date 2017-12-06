local Animation = require 'src.Animation'
local Constants = require 'src.Constants'
local Gamestate = require 'modules.hump.gamestate'
local Sprites = require 'src.Sprites'

local Title = {}

function Title:init()
    local font = love.graphics.newFont('res/font/redalert.ttf', 13)
    love.graphics.setFont(font)
end

function Title:enter()
    self.anim = Animation(Sprites.ui.LOGO, 3, 6)
end

function Title:update(dt)
    self.anim:update(dt)
end

function Title:mousepressed(x, y)
    local Game = require 'src.states.Game'
    Gamestate.switch(Game)
end

function Title:draw()
    self.anim:draw(Constants.GAME_WIDTH / 2, Constants.GAME_HEIGHT / 2 - 20,
        0, 1, 1, 192 / 2, 120 / 2)
    love.graphics.printf('made by @dvdfu for Ludum Dare 40',
        Constants.GAME_WIDTH / 2 - 128, Constants.GAME_HEIGHT / 2 + 36, 256, 'center')
end

return Title
