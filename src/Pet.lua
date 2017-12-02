local Class = require 'modules.hump.class'
local Animation = require 'src.Animation'
local Timer = require 'modules.hump.timer'
local Vector = require 'modules.hump.vector'

local Pet = Class.new()

local sprite = love.graphics.newImage('assets/pet/amanita.png')

local BODY_RADIUS = 6
local DAMPING = 0.3
local SPRITE_OFFSET = Vector(8, 8)

function Pet:init(world, x, y)
    self.scale = Vector(1, 1)
    self.anim = Animation(sprite, 2, 10)
    self.faceRight = true
    self.selected = false
    self.timer = Timer()

    self.body = self:newBody(world, x, y)
end

function Pet:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    local shape = love.physics.newCircleShape(BODY_RADIUS)
    local fixture = love.physics.newFixture(body, shape)
    fixture:setUserData(self)
    return body
end

function Pet:update(dt)
    local vx, vy = self.body:getLinearVelocity()
    if vx > 1 then self.faceRight = true end
    if vx < -1 then self.faceRight = false end

    local animSpeed = self.selected and 2 or 1
    self.anim:update(dt * animSpeed)
    self.timer:update(dt)
end

function Pet:contains(x, y)
    local delta = Vector(x - self.body:getX(), y - self.body:getY())
    return delta:len2() < BODY_RADIUS * BODY_RADIUS
end

function Pet:isSelected()
    return self.selected
end

function Pet:select()
    self.selected = true
    self.scale.x = 1.5
    self.scale.y = 0.5
    self.timer:clear()
    self.timer:tween(60, self.scale, {x = 1, y = 1}, 'out-elastic')
end

function Pet:unselect()
    self.selected = false
end

function Pet:move(x, y)
    self.body:setLinearVelocity(x - self.body:getX(), y - self.body:getY())
end

function Pet:draw()
    local direction = self.faceRight and 1 or -1
    self.anim:draw(self.body:getX(), self.body:getY(), 0, self.scale.x * direction, self.scale.y, SPRITE_OFFSET.x, SPRITE_OFFSET.y)
end

return Pet
