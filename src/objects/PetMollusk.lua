local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Pet = require 'src.objects.Pet'
local Vector = require 'modules.hump.vector'

local PetMollusk = Class.new()
PetMollusk:include(Pet)

local DAMPING = 0.6
local SHAPE = love.physics.newCircleShape(6)
local SPEED = 2
local MASS = 100
local SPRITE = love.graphics.newImage('res/img/pet/mollusk.png')

function PetMollusk:init(container, x, y)
    Pet.init(self, container, x, y)
    self:addTag('mollusk')
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

function PetMollusk:drag(x, y)
    local delta = Vector(x, y) - self:getPosition()
    self.body:setLinearVelocity(delta:trimmed(SPEED):unpack())
end

return PetMollusk
