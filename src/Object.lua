local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'

local Object = Class.new()

function Object:init(world, x, y)
    self.body = self:newBody(world, x, y)
    self.tags = {}
    self.destroyed = false
end

function Object:addTag(tag)
    self.tags[tag] = true
end

function Object:hasTag(tag)
    return self.tags[tag]
end

function Object:newBody(world, x, y)
    return love.physics.newBody(world, x, y, 'static')
end

function Object:getPosition()
    return Vector(self.body:getPosition())
end

function Object:collide(col, other) end

function Object:update(dt) end

function Object:destroy()
    self.destroyed = true
end

function Object:onDelete()
    self.body:destroy()
end

function Object:isDestroyed()
    return self.destroyed
end

function Object:draw() end

return Object
