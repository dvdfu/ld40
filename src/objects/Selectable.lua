local Class = require 'modules.hump.class'
local Object = require 'src.Object'
local Vector = require 'modules.hump.vector'

local Selectable = Class.new()
Selectable:include(Object)

local SHAPE = love.physics.newRectangleShape(16, 16)

function Selectable:init(container, x, y)
    Object.init(self, container, x, y)
    self:addTag('selectable')
    self.body:setBullet(true)
    self.selected = false
end

function Selectable:contains(x, y)
    return SHAPE:testPoint(self.body:getX(), self.body:getY(), 0, x, y)
end

function Selectable:isSelected()
    return self.selected
end

function Selectable:select()
    self.selected = true
end

function Selectable:unselect()
    self.selected = false
end

function Selectable:drag(x, y)
    local delta = Vector(x, y) - self:getPosition()
    delta:trimInplace(self:getMaxDragSpeed())
    self.body:setLinearVelocity(delta:unpack())
end

function Selectable:getMaxDragSpeed()
    return 30
end

return Selectable
