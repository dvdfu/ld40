local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Lava = require 'src.objects.Lava'
local WanderingPet = require 'src.objects.WanderingPet'
local Timer = require 'modules.hump.timer'

local PetDasher = Class.new()
PetDasher:include(WanderingPet)

local SHAPE = love.physics.newCircleShape(6)

local sprites = {
    idle = love.graphics.newImage('res/img/pet/dasher.png'),
    happy = love.graphics.newImage('res/img/pet/dasher_happy.png'),
    sad = love.graphics.newImage('res/img/pet/dasher_sad.png'),
}

local sound = love.audio.newSource('res/sfx/dasher.wav')

function PetDasher:init(container, x, y)
    WanderingPet.init(self, container, x, y, {
        damping = 0.1,
        immuneLava = true,
        payout = 2,
        sound = sound,
        wanderSpeed = 0.5,
        wanderDistanceMin = 64,
        wanderDistanceMax = 128,
        wanderDelayMin = 200,
        wanderDelayMax = 300,
    })
    self:addTag('dasher')
    self.animIdle = Animation(sprites.idle, 2, 10)
    self.animHappy = Animation(sprites.happy, 2, 10)
    self.animSad = Animation(sprites.happy, 2, 10)
    self.anim = self.animIdle
    self.lavaSpawnTimer = Timer()
    self.lavaSpawnTimer:every(20, function()
        local x, y = self.body:getPosition()
        Lava(self.container, x, y + 4)
    end)
    self.happyTimer = Timer()
end

function PetDasher:onCreateBody(body)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
end

function PetDasher:update(dt)
    WanderingPet.update(self, dt)
    if not self:isSelected() then
        self.lavaSpawnTimer:update(dt)
    end
    self.happyTimer:update(dt)
end

function PetDasher:onHappy()
    WanderingPet.onHappy(self)
    self.anim = self.animHappy
    self.happyTimer:clear()
    self.happyTimer:after(60, function() self.anim = self.animIdle end)
end

function PetDasher:onCry()
    self.anim = self.animSad
end

function PetDasher:select()
    WanderingPet.select(self)
    self:makeHappy()
end

return PetDasher
