local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Timer = require 'modules.hump.timer'
local WanderingPet = require 'src.objects.WanderingPet'

local PetAmanita = Class.new()
PetAmanita:include(WanderingPet)

local DAMPING = 0.3
local SHAPE = love.physics.newCircleShape(6)
local sprites = {
    idle = love.graphics.newImage('res/img/pet/amanita.png'),
    happy = love.graphics.newImage('res/img/pet/amanita_happy.png'),
    sad = love.graphics.newImage('res/img/pet/amanita_sad.png'),
}

local sound = love.audio.newSource('res/sfx/amanita.wav')

function PetAmanita:init(container, x, y)
    WanderingPet.init(self, container, x, y)
    self:addTag('amanita')
    self.animIdle = Animation(sprites.idle, 2, 10)
    self.animHappy = Animation(sprites.happy, 2, 10)
    self.animSad = Animation(sprites.sad, 2, 10)
    self.anim = self.animIdle
    self.happyTimer = Timer()
end

function PetAmanita:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
    return body
end

function PetAmanita:update(dt)
    WanderingPet.update(self, dt)
    self.happyTimer:update(dt)
end

function PetAmanita:collide(col, other, fixture)
    WanderingPet.collide(self, col, other, fixture)
    if other:hasTag('amanita') then
        self:resetTime()
    end
end

function PetAmanita:onCry()
    self.anim = self.animSad
end

function PetAmanita:onHappy()
    self:squish(1.4)
    self.anim = self.animHappy
    self.happyTimer:clear()
    self.happyTimer:after(60, function() self.anim = self.animIdle end)
end

function PetAmanita:getWanderSpeed()
    return 0.5
end

function PetAmanita:getWanderDistance()
    return math.random(4, 20)
end

function PetAmanita:getWanderDelay()
    return math.random(60, 120)
end

function PetAmanita:getPayout()
    return 1
end

function PetAmanita:getSound()
    return sound
end

return PetAmanita
