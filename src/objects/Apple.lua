local Class = require 'modules.hump.class'
local Selectable = require 'src.objects.Selectable'
local Squishable = require 'src.Squishable'
local Sounds = require 'src.Sounds'
local Sprites = require 'src.Sprites'

local Apple = Class.new()
Apple:include(Selectable)
Apple:include(Squishable)

local DAMPING = 1
local RADIUS = 6
local SHAPE = love.physics.newCircleShape(RADIUS)

function Apple:init(container, x, y)
    Selectable.init(self, container, x, y)
    Squishable.init(self)
    self:addTag('apple')
end

function Apple:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    return body
end

function Apple:update(dt)
    Selectable.update(self, dt)
    Squishable.update(self, dt)
end

function Apple:collide(col, other, fixture)
    if other:hasTag('lava') then
        self:destroy()
    end
end

function Apple:select()
    Selectable.select(self)
    self:squish()
    Sounds.object.APPLE:play()
end

function Apple:draw()
    local x, y = self.body:getPosition()
    local sx, sy = self:getSquish()
    love.graphics.draw(Sprites.object.APPLE, x, y, 0, sx, sy, 8, 8)
end

function Apple:getDrawOrder()
    return 2
end

return Apple
