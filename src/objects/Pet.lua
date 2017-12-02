local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Object = require 'src.Object'
local Timer = require 'modules.hump.timer'
local Vector = require 'modules.hump.vector'

local Pet = Class.new()
Pet:include(Object)

local DAMPING = 1
local EXCLAMATION_SPRITE = love.graphics.newImage('res/img/exclamation.png')
local SHAPE = love.physics.newRectangleShape(16, 16)
local SPRITE = love.graphics.newImage('res/img/pet/default.png')
local SPRITE_OFFSET = Vector(8, 8)

function Pet:init(world, x, y)
    Object.init(self, world, x, y)
    self:addTag('pet')
    self.body:setBullet(true)
    self.anim = self:newAnimation()
    self.scale = Vector(1, 1)
    self.scaleTimer = Timer()
    self.iconVisible = false
    self.iconTimer = Timer()
    self.faceRight = true
    self.selected = false
    self.deathTimer = Timer()
end

function Pet:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData(self)
    return body
end

function Pet:newAnimation()
    return Animation(SPRITE, 1, 1)
end

function Pet:update(dt)
    local vx, vy = self.body:getLinearVelocity()
    if vx > 0.1 then self.faceRight = true end
    if vx < -0.1 then self.faceRight = false end

    local animSpeed = self.selected and 2 or 1
    self.anim:update(dt * animSpeed)
    self.scaleTimer:update(dt)
    self.iconTimer:update(dt)
    self.deathTimer:update(dt)
end

function Pet:collide(col, other)
    if other:hasTag('apple') then
        other:destroy()
        self:squish(2)
    elseif other:hasTag('flower') then
        local vx, vy = self.body:getLinearVelocity()
        other:jostle(vx)
    end
end

function Pet:contains(x, y)
    return SHAPE:testPoint(self.body:getX(), self.body:getY(), 0, x, y)
end

function Pet:isSelected()
    return self.selected
end

function Pet:select()
    self.selected = true
    self:squish(2)
    self.iconVisible = true
    self.iconTimer:clear()
    self.iconTimer:after(60, function() self.iconVisible = false end)
end

function Pet:unselect()
    self.selected = false
end

function Pet:drag(x, y)
    self.body:setLinearVelocity(x - self.body:getX(), y - self.body:getY())
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

    if self.iconVisible then
        love.graphics.draw(EXCLAMATION_SPRITE,
            self.body:getX(), self.body:getY() - 16 * self.scale.y, 0,
            1, 1, 8, 8)
    end
end

return Pet
