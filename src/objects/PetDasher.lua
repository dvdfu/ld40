local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local WalkablePet = require 'src.objects.WalkablePet'

local PetDasher = Class.new()
PetDasher:include(WalkablePet)

local DAMPING = 0.1
local SHAPE = love.physics.newCircleShape(6)
local SPRITE = love.graphics.newImage('res/img/pet/dasher.png')

function PetDasher:init(container, x, y)
    WalkablePet.init(self, container, x, y)
    self.anim = Animation(SPRITE, 2, 10)
    self:addTag('dasher')
end

function PetDasher:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
    return body
end

function PetDasher:newAnimation()
    return Animation(SPRITE, 2, 8)
end

return PetDasher
