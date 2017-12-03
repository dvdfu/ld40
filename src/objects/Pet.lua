local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Particles = require 'src.Particles'
local Selectable = require 'src.objects.Selectable'
local Signal = require 'modules.hump.signal'
local Timer = require 'modules.hump.timer'
local Vector = require 'modules.hump.vector'

local Pet = Class.new()
Pet:include(Selectable)

local DAMPING = 1
local SHAPE = love.physics.newRectangleShape(16, 16)
local SPRITE = love.graphics.newImage('res/img/pet/default.png')
local SPRITE_OFFSET = Vector(8, 8)
local TIME_RESET = 60 * 18
local TIME_CRY = 60 * 12
local TIME_BAWL = 60 * 4

function Pet:init(container, x, y)
    Selectable.init(self, container, x, y)
    self:addTag('pet')
    self.scale = Vector(1, 1)
    self.scaleTimer = Timer()
    self.faceRight = true
    self.moneyTimer = Timer()
    self.moneyTimer:every(180, function() Signal.emit('payout') end)
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
    local vx, vy = self.body:getLinearVelocity()
    if vx > 0.1 then self.faceRight = true end
    if vx < -0.1 then self.faceRight = false end

    local animSpeed = self.selected and 2 or 1
    self.anim:update(dt * animSpeed)
    self.scaleTimer:update(dt)
    self.moneyTimer:update(dt)
    self.tearsTimer:update(dt)
    self.tears:update(dt)
    if self.timeLeft > 1 then
        self.timeLeft = self.timeLeft - 1
        if self.timeLeft == TIME_CRY then self:onCry() end
    else
        self:destroy()
    end
end

function Pet:collide(col, other, fixture)
    if fixture:getUserData() == 'body' then
        if other:hasTag('fireball') and not self:hasTag('dragon') then
            other:destroy()
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
    self:squish(2)
end

function Pet:squish(amount)
    self.scale.x = amount
    self.scale.y = 1 / amount
    self.scaleTimer:clear()
    self.scaleTimer:tween(60, self.scale, {x = 1, y = 1}, 'out-elastic')
end

function Pet:onCry() end

function Pet:onHappy() end

function Pet:resetTime()
    self.timeLeft = TIME_RESET
    self:squish(1.4)
    self:onHappy()
end

function Pet:draw()
    local direction = self.faceRight and 1 or -1
    self.anim:draw(
        self.body:getX(), self.body:getY(), 0,
        self.scale.x * direction, self.scale.y,
        SPRITE_OFFSET.x, SPRITE_OFFSET.y)
    love.graphics.draw(self.tears)
end

function Pet:getDrawOrder()
    return 3
end

return Pet
