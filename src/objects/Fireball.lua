local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Object = require 'src.Object'
local Timer = require 'modules.hump.timer'

local Fireball = Class.new()
Fireball:include(Object)

local LIFETIME = 150
local RADIUS = 6
local SHAPE = love.physics.newCircleShape(RADIUS)
local SPEED = 1
local SPRITE = love.graphics.newImage('res/img/fireball.png')

function Fireball:init(world, x, y, faceRight)
    Object.init(self, world, x, y)
    self:addTag('fireball')
    self.anim = Animation(SPRITE, 2, 1)
    local direction = faceRight and 1 or -1
    self.body:setLinearVelocity(SPEED * direction, 0)
    self.timer = Timer()
    self.timer:after(LIFETIME, function() self:destroy() end)
end

function Fireball:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setSensor(true)
    fixture:setUserData(self)
    return body
end

function Fireball:update(dt)
    self.anim:update(dt)
    self.timer:update(dt)
end

function Fireball:draw()
    self.anim:draw(self.body:getX(), self.body:getY(), 0, 1, 1, 8, 8)
end

return Fireball
