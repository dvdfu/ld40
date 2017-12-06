local Animation = require 'src.Animation'
local Constants = require 'src.Constants'
local Gamestate = require 'modules.hump.gamestate'
local Sprites = require 'src.Sprites'
local Timer = require 'modules.hump.timer'

local Results = {}

function Results:init()
    local font = love.graphics.newFont('res/font/redalert.ttf', 13)
    love.graphics.setFont(font)
end

function Results:enter(current, stats)
    self.anim = Animation(Sprites.ui.LOGO, 3, 6)
    self.stats = stats or {
        totalPets = 0,
        totalMoney = 0,
        time = 0,
    }
    self.dropPos = 0
    self.dropTimer = Timer()
    self.dropTimer:tween(60, self, {dropPos = 80}, 'in-bounce')
    self.time = 0
end

function Results:update(dt)
    self.anim:update(dt)
    self.dropTimer:update(dt)
    self.time = self.time + dt
end

function Results:mousepressed(x, y)
    local Title = require 'src.states.Title'
    Gamestate.switch(Title)
end

function Results:draw()
    self.anim:draw(Constants.GAME_WIDTH / 2, 8, 0, 1, 1, 192 / 2, 0)
    love.graphics.draw(Sprites.ui.CLOSED, Constants.GAME_WIDTH / 2, self.dropPos,
        math.pi / 24, 1, 1, 160 / 2, 56 / 2)

    local x = 72
    local y = 128
    love.graphics.draw(Sprites.ui.PET, x, y)
    love.graphics.print(self.stats.totalPets .. ' Critters Watched', x + 16, y - 1)

    y = y + 16
    love.graphics.draw(Sprites.ui.COIN, x, y)
    love.graphics.print(self.stats.totalMoney .. ' Earnings', x + 16, y - 1)

    y = y + 16
    love.graphics.draw(Sprites.ui.TIME, x, y)
    local seconds = math.ceil(self.stats.time / 60)
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    local time = minutes .. ':' .. seconds .. (seconds < 10 and '0' or '')
    love.graphics.print(time, x + 16, y - 1)
end

return Results
