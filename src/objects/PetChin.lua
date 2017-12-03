local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Pet = require 'src.objects.Pet'

local PetChin = Class.new()
PetChin:include(Pet)

local DAMPING = 0.3
local SHAPE = love.physics.newCircleShape(6)
local SPRITE = love.graphics.newImage('res/img/pet/chin.png')

function PetChin:init(container, x, y)
    Pet.init(self, container, x, y)
    self:addTag('chin')
end

function PetChin:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData(self)
    return body
end

function PetChin:newAnimation()
    return Animation(SPRITE, 2, 10)
end

return PetChin
