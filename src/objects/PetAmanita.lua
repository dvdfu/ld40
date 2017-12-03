local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Pet = require 'src.objects.Pet'
local Timer = require 'modules.hump.timer'
local Vector = require 'modules.hump.vector'

local PetAmanita = Class.new()
PetAmanita:include(Pet)

local DAMPING = 0.3
local MOVE_DISTANCE_MIN = 16
local MOVE_DISTANCE_MAX = 32
local MOVE_INTERVAL_MIN = 30
local MOVE_INTERVAL_MAX = 150
local SHAPE = love.physics.newCircleShape(6)
local SPEED = 0.5
local SPRITE = love.graphics.newImage('res/img/pet/amanita.png')

function PetAmanita:init(world, x, y)
    Pet.init(self, world, x, y)
    self:addTag('amanita')
    self.moveTimer = Timer()
    self.moveTarget = nil
    self:relocate()
end

function PetAmanita:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData(self)
    return body
end

function PetAmanita:newAnimation()
    return Animation(SPRITE, 2, 10)
end

function PetAmanita:update(dt)
    self.moveTimer:update(dt)
    if not self:isSelected() and self.moveTarget then
        local delta = (self.moveTarget - self:getPosition()):trimmed(SPEED)
        self.body:setLinearVelocity(delta:unpack())
    end
    Pet.update(self, dt)
end

function PetAmanita:unselect()
    Pet.unselect(self)
    self.moveTarget = nil
end

function PetAmanita:relocate()
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

-- function PetAmanita:draw()
--     Pet.draw(self)
--     love.graphics.circle('line', self.moveTarget.x, self.moveTarget.y, 3)
-- end

return PetAmanita
