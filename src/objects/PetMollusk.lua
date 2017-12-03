local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Pet = require 'src.objects.Pet'

local PetMollusk = Class.new()
PetMollusk:include(Pet)

local DAMPING = 0.6
local MASS = 100
local SHAPE = love.physics.newCircleShape(6)
local SPRITE = love.graphics.newImage('res/img/pet/mollusk.png')

function PetMollusk:init(container, x, y)
    Pet.init(self, container, x, y)
    self:addTag('mollusk')
    self.anim = Animation(SPRITE, 2, 10)
end

function PetMollusk:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    body:setMass(MASS)
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
    return body
end

function PetMollusk:newAnimation()
    return Animation(SPRITE, 2, 16)
end

function PetMollusk:collide(col, other, fixture)
    Pet.collide(self, col, other, fixture)
    if other:hasTag('apple') then
        other:destroy()
        self:resetTime()
    end
end

function PetMollusk:getMaxDragSpeed()
    return 2
end

return PetMollusk
