local Class = require 'modules.hump.class'
local Selectable = require 'src.objects.Selectable'
local Sounds = require 'src.Sounds'
local Sprites = require 'src.Sprites'

local Apple = Class.new()
Apple:include(Selectable)

local DAMPING = 1
local RADIUS = 6
local SHAPE = love.physics.newCircleShape(RADIUS)

function Apple:init(container, x, y)
    Selectable.init(self, container, x, y)
    self:addTag('apple')
end

function Apple:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    return body
end

function Apple:collide(col, other, fixture)
    if other:hasTag('lava') then
        self:destroy()
    end
end

function Apple:select()
    Selectable.select(self)
    Sounds.object.APPLE:play()
end

function Apple:draw()
    love.graphics.draw(Sprites.object.APPLE, self.body:getX(), self.body:getY(), 0, 1, 1, 8, 8)
end

function Apple:getDrawOrder()
    return 2
end

return Apple
