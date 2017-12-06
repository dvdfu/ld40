local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Pet = require 'src.objects.Pet'
local Vector = require 'modules.hump.vector'
local Timer = require 'modules.hump.timer'

local PetChin = Class.new()
PetChin:include(Pet)

local SHAPE = love.physics.newCircleShape(6)
local SNAG_LENGTH = 32
local SNAG_SHAPE = love.physics.newCircleShape(SNAG_LENGTH)

local sprites = {
    idle = love.graphics.newImage('res/img/pet/chin.png'),
    eat = love.graphics.newImage('res/img/pet/chin_eat.png'),
    tongueBody = love.graphics.newImage('res/img/tongue_body.png'),
    tongueTip = love.graphics.newImage('res/img/tongue_tip.png'),
}

local sound = love.audio.newSource('res/sfx/chin.wav')

function PetChin:init(container, x, y)
    Pet.init(self, container, x, y, {
        appleEater = true,
        payout = 2,
        sound = sound,
    })
    self:addTag('chin')
    self.animIdle = Animation(sprites.idle, 2, 10)
    self.animEat = Animation(sprites.eat, 2, 10)
    self.anim = self.animIdle
    self.tonguePos = Vector(x, y)
    self.tongueProgress = 0
    self.tongueTimer = Timer()
end

function PetChin:onCreateBody(body)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
    local snagFixture = love.physics.newFixture(body, SNAG_SHAPE)
    snagFixture:setSensor(true)
    snagFixture:setUserData('snag')
end

function PetChin:update(dt)
    Pet.update(self, dt)
    self.tongueTimer:update(dt)
end

function PetChin:collide(col, other, fixture)
    Pet.collide(self, col, other, fixture)
    if fixture:getUserData() == 'snag' then
        if other:hasTag('apple') and not other:isDestroyed() then
            self:snag(other:getPosition())
            other:destroy()
        end
    end
end

function PetChin:snag(target)
    self.anim = self.animEat
    self.tonguePos = target
    self.tongueProgress = 1
    self.tongueTimer:clear()
    self.tongueTimer:tween(30, self, {tongueProgress = 0}, 'in-cubic',
        function() self.anim = self.animIdle end)
    self:squish()
end

function PetChin:draw()
    Pet.draw(self)
    if self.tongueProgress > 0.01 then
        local pos = self:getPosition()
        pos.x = pos.x + self.direction
        pos.y = pos.y + 1
        local delta = (self.tonguePos - pos) * self.tongueProgress
        love.graphics.draw(sprites.tongueBody, pos.x, pos.y, delta:angleTo(), delta:len() / 6, 1, 0, 3)
        love.graphics.draw(sprites.tongueTip, pos.x + delta.x, pos.y + delta.y, 0, 1, 1, 3, 3)
    end
end

return PetChin
