local Class = require 'modules.hump.class'
local Selectable = require 'src.objects.Selectable'

local Apple = Class.new()
Apple:include(Selectable)

local DAMPING = 1
local RADIUS = 8
local SHAPE = love.physics.newCircleShape(RADIUS)
local SPRITE = love.graphics.newImage('res/img/apple.png')

function Apple:init(container, x, y)
    Selectable.init(self, container, x, y)
    self:addTag('apple')
end

function Apple:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setSensor(true)
    fixture:setUserData(self)
    return body
end

function Apple:draw()
    love.graphics.draw(SPRITE, self.body:getX(), self.body:getY(), 0, 1, 1, RADIUS, RADIUS)
end

function Apple:getDrawOrder()
    return 1
end

return Apple
