local Class = require 'modules.hump.class'
local Pet = require 'src.objects.Pet'
local Timer = require 'modules.hump.timer'
local Vector = require 'modules.hump.vector'

local WalkablePet = Class.new()
WalkablePet:include(Pet)

local MOVE_DISTANCE_MIN = 16
local MOVE_DISTANCE_MAX = 64
local MOVE_INTERVAL_MIN = 100
local MOVE_INTERVAL_MAX = 300
local SPEED = 0.5

function WalkablePet:init(container, x, y)
    Pet.init(self, container, x, y)
    self.moveTimer = Timer()
    self.moveTarget = nil
    self:relocate()
end

function WalkablePet:update(dt)
    self.moveTimer:update(dt)
    if not self:isSelected() and self.moveTarget then
        local delta = (self.moveTarget - self:getPosition()):trimmed(SPEED)
        self.body:setLinearVelocity(delta:unpack())
    end
    Pet.update(self, dt)
end

function WalkablePet:unselect()
    Pet.unselect(self)
    self.moveTarget = nil
end

function WalkablePet:relocate()
    if not self:isSelected() then
        local angle = math.random(0, math.pi * 2)
        local radius = math.random(MOVE_DISTANCE_MIN, MOVE_DISTANCE_MAX)
        local delta = Vector(math.cos(angle), math.sin(angle)) * radius
        self.moveTarget = self:getPosition() + delta
        self:squish(1.3)
    end

    local delay = math.random(MOVE_INTERVAL_MIN, MOVE_INTERVAL_MAX)
    self.moveTimer:clear()
    self.moveTimer:after(delay, function() self:relocate() end)
end

return WalkablePet
