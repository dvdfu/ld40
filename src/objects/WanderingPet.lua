local Class = require 'modules.hump.class'
local Pet = require 'src.objects.Pet'
local Timer = require 'modules.hump.timer'
local Vector = require 'modules.hump.vector'

local WanderingPet = Class.new()
WanderingPet:include(Pet)

local DEFAULT_PROPS = {
    wanderSpeed = 1,
    wanderDistanceMin = 100,
    wanderDistanceMax = 100,
    wanderDelayMin = 100,
    wanderDelayMax = 100,
}

function WanderingPet:init(container, x, y, props)
    props = props or {}
    for key, value in pairs(DEFAULT_PROPS) do
        if not props[key] then
            props[key] = value
        end
    end
    Pet.init(self, container, x, y, props)
    self.moveTimer = Timer()
    self.moveTarget = nil
    self:relocate()
end

function WanderingPet:update(dt)
    self.moveTimer:update(dt)
    if not self:isSelected() and self.moveTarget then
        local delta = self.moveTarget - self:getPosition()
        delta:trimInplace(self.props.wanderSpeed)
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
        local radius = math.random(self.props.wanderDistanceMin, self.props.wanderDistanceMax)
        local delta = Vector(math.cos(angle), math.sin(angle)) * radius
        self.moveTarget = self:getPosition() + delta
        self:squish(1.4)
    end

    self.moveTimer:clear()
    local wanderDelay = math.random(self.props.wanderDelayMin, self.props.wanderDelayMax)
    self.moveTimer:after(wanderDelay, function() self:relocate() end)
end

return WanderingPet
