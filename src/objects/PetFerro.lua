local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local WanderingPet = require 'src.objects.WanderingPet'

local PetFerro = Class.new()
PetFerro:include(WanderingPet)

local SHAPE = love.physics.newCircleShape(6)
local SPRITE = love.graphics.newImage('res/img/pet/ferro.png')

local sound = love.audio.newSource('res/sfx/ferro.wav')

function PetFerro:init(container, x, y)
    WanderingPet.init(self, container, x, y, {
        appleEater = true,
        payout = 3,
        sound = sound,
        wanderSpeed = 1,
        wanderDistanceMin = 80,
        wanderDistanceMax = 80,
        wanderDelayMin = 200,
        wanderDelayMax = 300,
    })
    self.anim = Animation(SPRITE, 2, 10)
    self:addTag('ferro')
end

function PetFerro:onCreateBody(body)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
end

return PetFerro
