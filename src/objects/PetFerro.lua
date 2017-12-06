local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Sounds = require 'src.Sounds'
local Sprites = require 'src.Sprites'
local WanderingPet = require 'src.objects.WanderingPet'

local PetFerro = Class.new()
PetFerro:include(WanderingPet)

local SHAPE = love.physics.newCircleShape(6)

function PetFerro:init(container, x, y)
    WanderingPet.init(self, container, x, y, {
        appleEater = true,
        payout = 3,
        sound = Sounds.pet.FERRO,
        wanderSpeed = 1,
        wanderDistanceMin = 80,
        wanderDistanceMax = 80,
        wanderDelayMin = 200,
        wanderDelayMax = 300,
    })
    self.anim = Animation(Sprites.pet.ferro.IDLE, 2, 10)
    self:addTag('ferro')
end

function PetFerro:onCreateBody(body)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
end

return PetFerro
