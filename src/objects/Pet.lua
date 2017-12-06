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
local TIME_CRY = 60 * 6
local TIME_BAWL = 60 * 2

local DEFAULT_PROPS = {
    dragSpeedMax = 30,
    immuneFireball = false,
    immuneLava = false,
    immuneSpike = false,
    payout = 1,
}

function Pet:init(container, x, y, props)
    props = props or {}
    for key, value in pairs(DEFAULT_PROPS) do
        if not props[key] then props[key] = value end
    end
    Selectable.init(self, container, x, y)
    Squishable.init(self)
    self:addTag('pet')
    self.props = props
    self.direction = 1

    self.moneyTimer = Timer()
    self.moneyTimer:every(180, function() Signal.emit('payout', self.props.payout) end)

    self.tears = Particles.newTears()
    self.tearSpawnTimer = Timer()
    self.tearSpawnTimer:every(1, function()
        local x, y = self.body:getPosition()
        self.tears:setPosition(x, y - 4)
        self.tears:emit(1)
    end)

    self.happiness = TIME_RESET

    self.iconOffset = 0
    self.iconTimer = Timer()

    self:shout()
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
    if vx > 0.1 then self.direction = 1 end
    if vx < -0.1 then self.direction = -1 end

    local animSpeed = self.selected and 2 or 1
    self.anim:update(dt * animSpeed)

    self.tears:update(dt)
    self.moneyTimer:update(dt)
    self.iconTimer:update(dt)
    if self.happiness < TIME_BAWL then
        self.tearSpawnTimer:update(dt / 3)
    elseif self.happiness < TIME_CRY then
        self.tearSpawnTimer:update(dt / 15)
    end

    if not self:hasTag('lumpy') then
        if self.happiness > dt then
            if self.happiness >= TIME_CRY and self.happiness - dt < TIME_CRY then
                self:onCry()
            end
            self.happiness = self.happiness - dt
        else
            self:destroy()
        end
    end
end

function Pet:collide(col, other, fixture)
    if fixture:getUserData() == 'body' then
        if self.props.appleEater and other:hasTag('apple') and not other:isDestroyed() then
            other:destroy()
            self:resetTime()
        elseif not self.props.immuneFireball and other:hasTag('fireball') then
            other:destroy()
            self:destroy()
        elseif not self.props.immuneLava and other:hasTag('lava') then
            self:destroy()
        elseif not self.props.immuneSpike and other:hasTag('ferro') then
            self:destroy()
        elseif other:hasTag('grass') then
            local vx, vy = self.body:getLinearVelocity()
            other:jostle(vx)
        end
    end
end

function Pet:contains(x, y)
    return SHAPE:testPoint(self.body:getX(), self.body:getY(), 0, x, y)
end

function Pet:select()
    Selectable.select(self)
    self:squish()
end

function Pet:getMaxDragSpeed()
    return self.props.dragSpeedMax
end

function Pet:onCry() end

function Pet:onHappy() end

function Pet:resetTime()
    self.happiness = TIME_RESET
    if not self:iconVisible() then
        self.iconOffset = 1
        self.iconTimer:clear()
        self.iconTimer:tween(30, self, {iconOffset = 0}, 'out-cubic')
        self:squish(1.4)
        self:onHappy()
    end
    self:shout()
end

function Pet:iconVisible()
    return self.iconOffset > 0.001
end

function Pet:shout(pitch)
    if not pitch then
        local a = 1.0595
        pitch = 1 / a + math.random() * (a - 1 / a)
    end
    self.props.sound:stop()
    self.props.sound:setPitch(pitch)
    self.props.sound:play()
    self.props.sound:setPitch(1)
end

function Pet:draw()
    local x, y = self.body:getPosition()
    local sx, sy = self:getSquish()
    self.anim:draw(x, y, 0, sx * self.direction, sy, SPRITE_OFFSET.x, SPRITE_OFFSET.y)
    love.graphics.draw(self.tears)
    if self:iconVisible() then
        love.graphics.draw(HEART_SPRITE, x, y - 8 + self.iconOffset * 16, 0, sx, sy, 5.5, 9)
    end
end

function Pet:getDrawOrder()
    return 3
end

return Pet
