local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Particles = require 'src.Particles'
local Selectable = require 'src.objects.Selectable'
local Signal = require 'modules.hump.signal'
local Squishable = require 'src.Squishable'
local Timer = require 'modules.hump.timer'
local Vector = require 'modules.hump.vector'

local Pet = Class.new()
Pet:include(Selectable)
Pet:include(Squishable)

local DAMPING = 1
local HEART_SPRITE = love.graphics.newImage('res/img/heart.png')
local SHAPE = love.physics.newRectangleShape(16, 16)
local SPRITE = love.graphics.newImage('res/img/pet/default.png')
local SPRITE_OFFSET = Vector(8, 8)
local TIME_RESET = 60 * 18
local TIME_CRY = 60 * 8
local TIME_BAWL = 60 * 4

function Pet:init(container, x, y)
    Selectable.init(self, container, x, y)
    Squishable.init(self)
    self:addTag('pet')
    self.faceRight = true
    self.moneyTimer = Timer()
    self.moneyTimer:every(180, function() Signal.emit('payout', self:getPayout()) end)
    self.tears = Particles.newTears()
    self.tearsTimer = Timer()
    self.tearsTimer:every(15, function()
        if self.timeLeft < TIME_CRY then
            local x, y = self.body:getPosition()
            self.tears:setPosition(x, y - 4)
            self.tears:emit(1)
            if self.timeLeft < TIME_BAWL then
                self.tears:emit(3)
            end
        end
    end)
    self.timeLeft = TIME_RESET
    self.iconVisible = false
    self.iconOffset = 0
    self.iconTimer = Timer()
    self:getSound():play()
end

function Pet:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
    return body
end

function Pet:update(dt)
    Squishable.update(self, dt)
    local vx, vy = self.body:getLinearVelocity()
    if vx > 0.1 then self.faceRight = true end
    if vx < -0.1 then self.faceRight = false end

    local animSpeed = self.selected and 2 or 1
    self.anim:update(dt * animSpeed)
    self.moneyTimer:update(dt)
    self.iconTimer:update(dt)
    self.tearsTimer:update(dt)
    self.tears:update(dt)
    if self.timeLeft > 1 then
        if not self:hasTag('lumpy') then
            self.timeLeft = self.timeLeft - 1
        end
        if self.timeLeft == TIME_CRY then self:onCry() end
    else
        self:destroy()
    end
end

function Pet:collide(col, other, fixture)
    if fixture:getUserData() == 'body' then
        if other:hasTag('fireball') and not self:fireballImmune() then
            other:destroy()
            self:destroy()
        elseif other:hasTag('lava') and not self:lavaImmune() then
            self:destroy()
        elseif other:hasTag('ferro') and not self:spikeImmune() then
            self:destroy()
        elseif other:hasTag('grass') then
            local vx, vy = self.body:getLinearVelocity()
            other:jostle(vx)
        end
    end
end

function Pet:fireballImmune()
    return false
end

function Pet:lavaImmune()
    return false
end

function Pet:spikeImmune()
    return false
end

function Pet:contains(x, y)
    return SHAPE:testPoint(self.body:getX(), self.body:getY(), 0, x, y)
end

function Pet:select()
    Selectable.select(self)
    self:squish()
    self:getSound():play()
end

function Pet:onCry() end

function Pet:onHappy()
    self:squish(1.4)
end

function Pet:resetTime()
    self.timeLeft = TIME_RESET
    if not self.iconVisible then
        self.iconVisible = true
        self.iconOffset = 1
        self.iconTimer:clear()
        self.iconTimer:tween(30, self, {iconOffset = 0}, 'out-cubic',
            function() self.iconVisible = false end)
        self:onHappy()
    end
    self:getSound():play()
end

function Pet:getPayout()
    return 2
end

function Pet:draw()
    local direction = self.faceRight and 1 or -1
    local x, y = self.body:getPosition()
    local sx, sy = self:getSquish()
    self.anim:draw(x, y, 0, sx * direction, sy, SPRITE_OFFSET.x, SPRITE_OFFSET.y)
    love.graphics.draw(self.tears)
    if self.iconVisible then
        love.graphics.draw(HEART_SPRITE, x, y - 8 + self.iconOffset * 16, 0, sx, sy, 5.5, 9)
    end
end

function Pet:getDrawOrder()
    return 3
end

return Pet
