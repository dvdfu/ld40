local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Timer = require 'modules.hump.timer'
local WanderingPet = require 'src.objects.WanderingPet'

local PetAmanita = Class.new()
PetAmanita:include(WanderingPet)

local SHAPE = love.physics.newCircleShape(6)
local sprites = {
    idle = love.graphics.newImage('res/img/pet/amanita.png'),
    happy = love.graphics.newImage('res/img/pet/amanita_happy.png'),
    sad = love.graphics.newImage('res/img/pet/amanita_sad.png'),
}

local sound = love.audio.newSource('res/sfx/amanita.wav')

function PetAmanita:init(container, x, y)
    WanderingPet.init(self, container, x, y, {
        damping = 0.3,
        payout = 1,
        sound = sound,
        wanderSpeed = 0.5,
        wanderDistanceMin = 4,
        wanderDistanceMax = 20,
        wanderDelayMin = 60,
        wanderDelayMax = 120,
    })
    self:addTag('amanita')
    self.animIdle = Animation(sprites.idle, 2, 10)
    self.animHappy = Animation(sprites.happy, 2, 10)
    self.animSad = Animation(sprites.sad, 2, 10)
    self.anim = self.animIdle
    self.happyTimer = Timer()
end

function PetAmanita:onCreateBody(body)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
end

function PetAmanita:update(dt)
    WanderingPet.update(self, dt)
    self.happyTimer:update(dt)
end

function PetAmanita:collide(col, other, fixture)
    WanderingPet.collide(self, col, other, fixture)
    if other:hasTag('amanita') then
        self:makeHappy()
    end
end

function PetAmanita:onCry()
    self.anim = self.animSad
end

function PetAmanita:onHappy()
    self.anim = self.animHappy
    self.happyTimer:clear()
    self.happyTimer:after(60, function() self.anim = self.animIdle end)
end

return PetAmanita
