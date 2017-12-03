local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
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

function Pet:init(container, x, y)
    Selectable.init(self, container, x, y)
    self:addTag('pet')
    self.scale = Vector(1, 1)
    self.scaleTimer = Timer()
    self.faceRight = true
    self.moneyTimer = Timer()
    self.moneyTimer:every(180, function() Signal.emit('payout') end)
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
end

function Pet:collide(col, other, fixture)
    if fixture:getUserData() == 'body' then
        if other:hasTag('apple') then
            other:destroy()
            self:squish(2)
        elseif other:hasTag('fireball') and not self:hasTag('dragon') then
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

function Pet:draw()
    local direction = self.faceRight and 1 or -1
    self.anim:draw(
        self.body:getX(), self.body:getY(), 0,
        self.scale.x * direction, self.scale.y,
        SPRITE_OFFSET.x, SPRITE_OFFSET.y)
end

function Pet:getDrawOrder()
    return 3
end

return Pet
