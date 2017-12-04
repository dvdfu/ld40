local Class = require 'modules.hump.class'
local Constants = require 'src.Constants'
local Object = require 'src.Object'
local Timer = require 'modules.hump.timer'
local Vector = require 'modules.hump.vector'

local AppleCrate = Class.new()
AppleCrate:include(Object)

local SHAPE = love.physics.newRectangleShape(30, 18)

local sprites = {
    crate = love.graphics.newImage('res/img/apple_crate.png'),
    coin = love.graphics.newImage('res/img/coin.png'),
}

function AppleCrate:init(container, x, y)
    Object.init(self, container, x, y)
    self:addTag('solid')
    self:addTag('crate')
    self.showText = false
    self.scale = Vector(1, 1)
    self.scaleTimer = Timer()
end

function AppleCrate:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'static')
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    return body
end

function AppleCrate:contains(x, y)
    return SHAPE:testPoint(self.body:getX(), self.body:getY(), 0, x, y)
end

function AppleCrate:update(dt)
    Object.update(self, dt)
    self.scaleTimer:update(dt)
end

function AppleCrate:onClick()
    self.showText = true
    self.scale.x = 1.5
    self.scale.y = 1 / 1.5
    self.scaleTimer:clear()
    self.scaleTimer:tween(40, self.scale, {x = 1, y = 1}, 'out-elastic')
    self.scaleTimer:after(80, function() self.showText = false end)
end

function AppleCrate:draw()
    local x = self.body:getX()
    local y = self.body:getY() + 12
    love.graphics.draw(sprites.crate, x, y, 0, self.scale.x, self.scale.y, 16, 24)

    if self.showText then
        local offset = 8 * (self.scale.y - 1)
        love.graphics.draw(sprites.coin, x + 8, y + 10 + offset, 0, self.scale.x, self.scale.y, 8, 8)
        love.graphics.print('-' .. 5, x - 12, y + 1 + offset)
    end
end

function AppleCrate:getDrawOrder()
    return 1
end

return AppleCrate
