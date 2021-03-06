local Class = require 'modules.hump.class'
local Constants = require 'src.Constants'
local Object = require 'src.Object'
local Sprites = require 'src.Sprites'
local Squishable = require 'src.Squishable'

local AppleCrate = Class.new()
AppleCrate:include(Object)
AppleCrate:include(Squishable)

local SHAPE = love.physics.newRectangleShape(30, 18)

function AppleCrate:init(container, x, y)
    Object.init(self, container, x, y)
    Squishable.init(self)
    self:addTag('solid')
    self:addTag('crate')
    self.showText = false
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
    Squishable.update(self, dt)
end

function AppleCrate:onClick()
    self.showText = true
    self:squish(1.4)
end

function AppleCrate:draw()
    local x = self.body:getX()
    local y = self.body:getY() + 12
    local sx, sy = self:getSquish()
    love.graphics.draw(Sprites.object.CRATE, x, y, 0, sx, sy, 16, 24)

    if self:isSquished() then
        local offset = 8 * (sy - 1)
        love.graphics.draw(Sprites.ui.COIN, x + 8, y + 10 + offset, 0, sx, sy, 8, 8)
        love.graphics.print('-' .. 5, x - 12, y + 1 + offset)
    end
end

function AppleCrate:getDrawOrder()
    return 1
end

return AppleCrate
