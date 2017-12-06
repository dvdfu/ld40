local Class = require 'modules.hump.class'
local Constants = require 'src.Constants'
local Object = require 'src.Object'
local Sprites = require 'src.Sprites'
local Squishable = require 'src.Squishable'

local Nest = Class.new()
Nest:include(Object)
Nest:include(Squishable)

local SHAPE = love.physics.newRectangleShape(18, 26)

function Nest:init(container, x, y)
    Object.init(self, container, x, y)
    Squishable.init(self)
    self:addTag('solid')
    self:addTag('nest')
    self.showText = false
end

function Nest:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'static')
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    return body
end

function Nest:contains(x, y)
    return SHAPE:testPoint(self.body:getX(), self.body:getY(), 0, x, y)
end

function Nest:update(dt)
    Object.update(self, dt)
    Squishable.update(self, dt)
end

function Nest:onClick()
    self:squish(1.4)
end

function Nest:draw()
    local x = self.body:getX()
    local y = self.body:getY()
    local sx, sy = self:getSquish()
    love.graphics.draw(Sprites.object.NEST, x, y, 0, sx, sy, 16, 16)
end

function Nest:getDrawOrder()
    return 1
end

return Nest
