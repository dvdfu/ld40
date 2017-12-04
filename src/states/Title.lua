local Animation = require 'src.Animation'
local Constants = require 'src.Constants'
local Gamestate = require 'modules.hump.gamestate'
local Timer = require 'modules.hump.timer'

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
    self.overlayPos = 1
    self.overlayTimer = Timer()
    self.overlayTimer:tween(30, self, {overlayPos = 0}, 'in-cubic',
        function() self.overlayPos = 0 end)
end

function Title:update(dt)
    self.anim:update(dt)
    self.overlayTimer:update(dt)
end

function Title:mousepressed(x, y)
    if self.overlayPos == 0 then
        self.overlayTimer:tween(30, self, {overlayPos = 1}, 'in-cubic', function()
            local Game = require 'src.states.Game'
            Gamestate.switch(Game)
        end)
    end
end

function Title:draw()
    self.anim:draw(Constants.GAME_WIDTH / 2, Constants.GAME_HEIGHT / 2 - 20,
        0, 1, 1, 192 / 2, 120 / 2)
    love.graphics.printf('made in 2 days for Ludum Dare 40\n@dvdfu',
        Constants.GAME_WIDTH / 2 - 128, Constants.GAME_HEIGHT / 2 + 36, 256, 'center')

    if self.overlayPos > 0 then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('fill', 0, Constants.GAME_HEIGHT * (1 - self.overlayPos),
            Constants.GAME_WIDTH, Constants.GAME_HEIGHT)
        love.graphics.setColor(255, 255, 255)
    end
end

return Title
