local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local WalkablePet = require 'src.objects.WalkablePet'

local PetAmanita = Class.new()
PetAmanita:include(WalkablePet)

local DAMPING = 0.3
local SHAPE = love.physics.newCircleShape(6)
local SPRITE = love.graphics.newImage('res/img/pet/amanita.png')

function PetAmanita:init(container, x, y)
    WalkablePet.init(self, container, x, y)
    self:addTag('amanita')
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

return PetAmanita
