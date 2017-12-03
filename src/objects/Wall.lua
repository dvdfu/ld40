local Class = require 'modules.hump.class'
local Object = require 'src.Object'
local Vector = require 'modules.hump.vector'

local Wall = Class.new()
Wall:include(Object)

function Wall:init(container, x, y, w, h)
    self.size = Vector(w, h)
    Object.init(self, container, x + w / 2, y + h / 2)
end

function Wall:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'static')
    local shape = love.physics.newRectangleShape(self.size:unpack())
    local fixture = love.physics.newFixture(body, shape)
    fixture:setUserData(self)
    return body
end

function Wall:update(dt)
end

function Wall:draw()
    love.graphics.rectangle('fill',
        self.body:getX() - self.size.x / 2, self.body:getY() - self.size.y / 2,
        self.size.x, self.size.y)
end

return Wall
