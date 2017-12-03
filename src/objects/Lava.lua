local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Object = require 'src.Object'
local Timer = require 'modules.hump.timer'

local Lava = Class.new()
Lava:include(Object)

local LIFETIME = 90
local RADIUS = 4
local SHAPE = love.physics.newCircleShape(RADIUS)
local SPEED = 1
local SPRITE = love.graphics.newImage('res/img/lava.png')

function Lava:init(container, x, y)
    Object.init(self, container, x, y)
    self:addTag('lava')
    self.anim = Animation(SPRITE, 4, 10)
    self.timer = Timer()
    self.timer:after(LIFETIME, function() self:destroy() end)
end

function Lava:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'static')
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setSensor(true)
    return body
end

function Lava:update(dt)
    self.anim:update(dt)
    self.timer:update(dt)
end

function Lava:collide(col, other, fixture)
    if other:hasTag('apple') then
        other:destroy()
    end
end

function Lava:draw()
    self.anim:draw(self.body:getX(), self.body:getY(), 0, 1, 1, 8, 5)
end

return Lava
