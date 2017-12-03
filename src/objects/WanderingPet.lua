local Class = require 'modules.hump.class'
local Pet = require 'src.objects.Pet'
local Timer = require 'modules.hump.timer'
local Vector = require 'modules.hump.vector'

local WanderingPet = Class.new()
WanderingPet:include(Pet)

function WanderingPet:init(container, x, y)
    Pet.init(self, container, x, y)
    self.moveTimer = Timer()
    self.moveTarget = nil
    self:relocate()
end

function WanderingPet:update(dt)
    self.moveTimer:update(dt)
    if not self:isSelected() and self.moveTarget then
        local delta = self.moveTarget - self:getPosition()
        delta:trimInplace(self:getWanderSpeed())
        self.body:setLinearVelocity(delta:unpack())
    end
    Pet.update(self, dt)
end

function WanderingPet:unselect()
    Pet.unselect(self)
    self.moveTarget = nil
end

function WanderingPet:relocate()
    if not self:isSelected() then
        local angle = math.random() * math.pi * 2
        local radius = self:getWanderDistance()
        local delta = Vector(math.cos(angle), math.sin(angle)) * radius
        self.moveTarget = self:getPosition() + delta
        self:squish(1.3)
    end

    self.moveTimer:clear()
    self.moveTimer:after(self:getWanderDelay(), function() self:relocate() end)
end

function WanderingPet:getWanderSpeed()
    return 0.5
end

function WanderingPet:getWanderDistance()
    return math.random(16, 64)
end

function WanderingPet:getWanderDelay()
    return math.random(100, 300)
end

return WanderingPet
