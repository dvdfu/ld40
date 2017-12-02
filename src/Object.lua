local Class = require 'modules.hump.class'

local Object = Class.new()

function Object:init(world, x, y)
    self.body = self:newBody(world, x, y)
    self.tags = {}
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

function Object:collide(col, other) end

function Object:update(dt) end

function Object:isDead()
    return false
end

function Object:draw() end

return Object
