local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Object = require 'src.Object'
local Timer = require 'modules.hump.timer'

local Fireball = Class.new()
Fireball:include(Object)

local LIFETIME = 90
local RADIUS = 6
local SHAPE = love.physics.newCircleShape(RADIUS)
local SPEED = 1
local SPRITE = love.graphics.newImage('res/img/fireball.png')

function Fireball:init(container, x, y, faceRight)
    Object.init(self, container, x, y)
    self:addTag('fireball')
    self.anim = Animation(SPRITE, 2, 5)
    local direction = faceRight and 1 or -1
    self.body:setLinearVelocity(SPEED * direction, 0)
    self.timer = Timer()
    self.timer:after(LIFETIME, function() self:destroy() end)
end

function Fireball:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setSensor(true)
    return body
end

function Fireball:update(dt)
    self.anim:update(dt)
    self.timer:update(dt)
end

function Fireball:collide(col, other, fixture)
    if other:hasTag('solid') then
        self:destroy()
    elseif other:hasTag('apple') then
        other:destroy()
    elseif other:hasTag('pet') and fixture:getUserData() == 'body' and not other:hasTag('dragon') then
        other:destroy()
        self:destroy()
    end
end

function Fireball:draw()
    self.anim:draw(self.body:getX(), self.body:getY(), 0, 1, 1, 8, 8)
end

function Fireball:getDrawOrder()
    return 2
end

return Fireball
