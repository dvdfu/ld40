local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Lava = require 'src.objects.Lava'
local WanderingPet = require 'src.objects.WanderingPet'
local Timer = require 'modules.hump.timer'

local PetDasher = Class.new()
PetDasher:include(WanderingPet)

local DAMPING = 0.1
local SHAPE = love.physics.newCircleShape(6)

local sprites = {
    idle = love.graphics.newImage('res/img/pet/dasher.png'),
    happy = love.graphics.newImage('res/img/pet/dasher_happy.png'),
}

function PetDasher:init(container, x, y)
    WanderingPet.init(self, container, x, y)
    self.animIdle = Animation(sprites.idle, 2, 10)
    self.animHappy = Animation(sprites.happy, 2, 10)
    self.anim = self.animIdle
    self:addTag('dasher')
    self.lavaTimer = Timer()
    self.lavaTimer:every(20, function()
        if not self:isSelected() then
            local x, y = self.body:getPosition()
            Lava(self.container, x, y + 4)
        end
    end)
    self.happyTimer = Timer()
end

function PetDasher:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
    return body
end

function PetDasher:update(dt)
    WanderingPet.update(self, dt)
    self.lavaTimer:update(dt)
    self.happyTimer:update(dt)
end

function PetDasher:onHappy()
    self:squish(1.4)
    self.anim = self.animHappy
    self.happyTimer:clear()
    self.happyTimer:after(60, function() self.anim = self.animIdle end)
end

function PetDasher:select()
    WanderingPet.select(self)
    self:resetTime()
end

function PetDasher:lavaImmune()
    return true
end

function PetDasher:getWanderSpeed()
    return 0.5
end

function PetDasher:getWanderDistance()
    return math.random(64, 128)
end

function PetDasher:getWanderDelay()
    return math.random(200, 300)
end

return PetDasher
