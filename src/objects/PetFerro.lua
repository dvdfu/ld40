local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local WanderingPet = require 'src.objects.WanderingPet'

local PetFerro = Class.new()
PetFerro:include(WanderingPet)

local DAMPING = 1
local SHAPE = love.physics.newCircleShape(6)
local SPRITE = love.graphics.newImage('res/img/pet/ferro.png')

function PetFerro:init(container, x, y)
    WanderingPet.init(self, container, x, y)
    self.anim = Animation(SPRITE, 2, 10)
    self:addTag('ferro')
end

function PetFerro:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
    return body
end

function PetFerro:collide(col, other, fixture)
    WanderingPet.collide(self, col, other, fixture)
    if other:hasTag('apple') then
        other:destroy()
        self:resetTime()
    end
end

return PetFerro