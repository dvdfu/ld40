local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Pet = require 'src.objects.Pet'

local PetMollusk = Class.new()
PetMollusk:include(Pet)

local DAMPING = 0.6
local SHAPE = love.physics.newCircleShape(6)
local SPRITE = love.graphics.newImage('res/img/pet/mollusk.png')

function PetMollusk:init(world, x, y)
    Pet.init(self, world, x, y)
    self:addTag('mollusk')
end

function PetMollusk:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData(self)
    return body
end

function PetMollusk:newAnimation()
    return Animation(SPRITE, 2, 16)
end

return PetMollusk
