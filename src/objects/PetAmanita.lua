local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Particles = require 'src.Particles'
local Timer = require 'modules.hump.timer'
local WalkablePet = require 'src.objects.WalkablePet'

local PetAmanita = Class.new()
PetAmanita:include(WalkablePet)

local DAMPING = 0.3
local TIME_HAPPY = 60 * 12
local TIME_CRY = 60 * 6
local TIME_BAWL = 60 * 3
local SHAPE = love.physics.newCircleShape(6)
local sprites = {
    idle = love.graphics.newImage('res/img/pet/amanita.png'),
    happy = love.graphics.newImage('res/img/pet/amanita_happy.png'),
    sad = love.graphics.newImage('res/img/pet/amanita_sad.png'),
}

function PetAmanita:init(container, x, y)
    WalkablePet.init(self, container, x, y)
    self:addTag('amanita')
    self.animIdle = Animation(sprites.idle, 2, 10)
    self.animHappy = Animation(sprites.happy, 2, 10)
    self.animSad = Animation(sprites.sad, 2, 10)
    self.anim = self.animIdle
    self.tears = Particles.newTears()
    self.tearsTimer = Timer()
    self.tearsTimer:every(10, function()
        local x, y = self.body:getPosition()
        self.tears:setPosition(x, y - 4)
        if self.timeLeft < TIME_BAWL then
            self.tears:emit(4)
        elseif self.timeLeft < TIME_CRY then
            self.tears:emit(1)
        end
    end)
    self.happyTimer = Timer()
    self.timeLeft = TIME_HAPPY
end

function PetAmanita:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
    return body
end

function PetAmanita:newAnimation()
    return Animation(SPRITE, 2, 10)
end

function PetAmanita:update(dt)
    WalkablePet.update(self, dt)
    self.happyTimer:update(dt)
    self.tearsTimer:update(dt)
    self.tears:update(dt)
    if self.timeLeft > 1 then
        self.timeLeft = self.timeLeft - 1
        if self.timeLeft == TIME_CRY then
            self.anim = self.animSad
        end
    else
        self:destroy()
    end
end

function PetAmanita:collide(col, other, fixture)
    WalkablePet.collide(self, col, other, fixture)
    if other:hasTag('amanita') then
        self.timeLeft = TIME_HAPPY
        self:squish(1.4)
        self.anim = self.animHappy
        self.happyTimer:clear()
        self.happyTimer:after(60, function() self.anim = self.animIdle end)
    end
end

function PetAmanita:draw()
    WalkablePet.draw(self)
    love.graphics.draw(self.tears)
end


return PetAmanita
