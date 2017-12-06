local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Pet = require 'src.objects.Pet'
local Sounds = require 'src.Sounds'
local Sprites = require 'src.Sprites'

local PetMollusk = Class.new()
PetMollusk:include(Pet)

local MASS = 100
local SHAPE = love.physics.newCircleShape(6)

function PetMollusk:init(container, x, y)
    Pet.init(self, container, x, y, {
        appleEater = true,
        dragSpeedMax = 1,
        immuneSpike = true,
        payout = 2,
        sound = Sounds.pet.MOLLUSK,
    })
    self:addTag('mollusk')
    self.anim = Animation(Sprites.pet.mollusk.IDLE, 2, 10)
end

function PetMollusk:onCreateBody(body)
    body:setMass(MASS)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
end

return PetMollusk
