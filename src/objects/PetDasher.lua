local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Pet = require 'src.objects.Pet'

local PetDasher = Class.new()
PetDasher:include(Pet)

local DAMPING = 0.1
local SHAPE = love.physics.newCircleShape(6)
local SPRITE = love.graphics.newImage('res/img/pet/dasher.png')

function PetDasher:init(container, x, y)
    Pet.init(self, container, x, y)
    self:addTag('dasher')
end

function PetDasher:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData(self)
    return body
end

function PetDasher:newAnimation()
    return Animation(SPRITE, 2, 8)
end

return PetDasher
