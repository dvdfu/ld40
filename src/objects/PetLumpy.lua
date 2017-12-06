local Animation = require 'src.Animation'
local Apple = require 'src.objects.Apple'
local Class = require 'modules.hump.class'
local Timer = require 'modules.hump.timer'
local WanderingPet = require 'src.objects.WanderingPet'

local PetLumpy = Class.new()
PetLumpy:include(WanderingPet)

local DAMPING = 0.1
local SHAPE = love.physics.newCircleShape(6)
local SENSOR_SHAPE = love.physics.newCircleShape(10)

local sprites = {
    idle = love.graphics.newImage('res/img/pet/lumpy.png'),
    scared = love.graphics.newImage('res/img/pet/lumpy_scared.png'),
}

local sound = love.audio.newSource('res/sfx/lumpy.wav')

function PetLumpy:init(container, x, y)
    WanderingPet.init(self, container, x, y, {
        immuneFireball = true,
        immuneLava = true,
        immuneSpike = true,
        payout = 0,
        wanderSpeed = 0.4,
        wanderDistanceMin = 24,
        wanderDistanceMax = 40,
        wanderDelayMin = 90,
        wanderDelayMax = 150,
    })
    self.animIdle = Animation(sprites.idle, 2, 10)
    self.animScared = Animation(sprites.scared, 2, 5)
    self.anim = self.animIdle
    self.scared = false
    self.scaredTimer = Timer()
    self.appleTimer = Timer()
    self.appleTimer:every(360, function()
        local x, y = self.body:getPosition()
        Apple(self.container, x, y + 8)
    end)
    self:addTag('lumpy')
end

function PetLumpy:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
    local sensorFixture = love.physics.newFixture(body, SENSOR_SHAPE)
    sensorFixture:setSensor(true)
    sensorFixture:setUserData('sensor')
    return body
end

function PetLumpy:update(dt)
    WanderingPet.update(self, dt)
    self.scaredTimer:update(dt)
    self.appleTimer:update(dt)
end

function PetLumpy:collide(col, other, fixture)
    WanderingPet.collide(self, col, other, fixture)
    if fixture:getUserData() == 'sensor' and
        other:hasTag('tombstone') and not self.scared then
        self:scareSelf()
    end
end

function PetLumpy:scareSelf()
    self.scared = true
    self.anim = self.animScared
    self.scaredTimer:after(40, function() self:destroy() end)
    self.scaredTimer:every(15, function()
        local x, y = self.body:getPosition()
        self.tears:setPosition(x, y - 4)
        self.tears:emit(4)
    end)
end
function PetLumpy:getSound()
    return sound
end

return PetLumpy
