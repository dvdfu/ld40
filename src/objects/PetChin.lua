local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Pet = require 'src.objects.Pet'
local Vector = require 'modules.hump.vector'
local Timer = require 'modules.hump.timer'

local PetChin = Class.new()
PetChin:include(Pet)

local DAMPING = 0.3
local SHAPE = love.physics.newCircleShape(6)
local SNAG_LENGTH = 32
local SNAG_SHAPE = love.physics.newCircleShape(SNAG_LENGTH)

local sprites = {
    idle = love.graphics.newImage('res/img/pet/chin.png'),
    eat = love.graphics.newImage('res/img/pet/chin_eat.png'),
    tongueBody = love.graphics.newImage('res/img/tongue_body.png'),
    tongueTip = love.graphics.newImage('res/img/tongue_tip.png'),
}

function PetChin:init(container, x, y)
    Pet.init(self, container, x, y)
    self:addTag('chin')
    self.animIdle = Animation(sprites.idle, 2, 10)
    self.animEat = Animation(sprites.eat, 2, 10)
    self.anim = self.animIdle
    self.tonguePos = Vector(x, y)
    self.tongueProgress = 0
    self.tongueTimer = Timer()
end

function PetChin:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
    local snagFixture = love.physics.newFixture(body, SNAG_SHAPE)
    snagFixture:setSensor(true)
    snagFixture:setUserData('snag')
    return body
end

function PetChin:update(dt)
    if self.tongueProgress > 0.01 then
        self.anim = self.animEat
    else
        self.anim = self.animIdle
    end
    Pet.update(self, dt)
    self.tongueTimer:update(dt)
end

function PetChin:collide(col, other, fixture)
    Pet.collide(self, col, other, fixture)
    if other:hasTag('apple') and not other:isDestroyed() then
        if fixture:getUserData() == 'snag' then
            self:snag(other:getPosition())
        end
        other:destroy()
        self:resetTime()
    end
end

function PetChin:snag(target)
    self.tonguePos = target
    self.tongueTimer:clear()
    self.tongueProgress = 1
    self.tongueTimer:tween(30, self, {tongueProgress = 0}, 'in-cubic')
    self:squish(2)
end

function PetChin:draw()
    Pet.draw(self)
    if self.tongueProgress > 0.01 then
        local pos = self:getPosition()
        pos.x = pos.x + (self.faceRight and 1 or -1)
        pos.y = pos.y + 1
        local delta = (self.tonguePos - pos) * self.tongueProgress
        love.graphics.draw(sprites.tongueBody, pos.x, pos.y, delta:angleTo(), delta:len() / 6, 1, 0, 3)
        love.graphics.draw(sprites.tongueTip, pos.x + delta.x, pos.y + delta.y, 0, 1, 1, 3, 3)
    end
end

return PetChin
