local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Object = require 'src.Object'
local Sprites = require 'src.Sprites'
local Timer = require 'modules.hump.timer'

local Fireball = Class.new()
Fireball:include(Object)

local LIFETIME = 90
local RADIUS = 6
local SHAPE = love.physics.newCircleShape(RADIUS)
local SPEED = 1

local sounds = {
    FIREBALL_SHOOT = love.audio.newSource('res/sfx/fireball_shoot.wav'),
    FIREBALL_HIT = love.audio.newSource('res/sfx/fireball_hit.wav'),
}

function Fireball:init(container, x, y, direction)
    Object.init(self, container, x, y)
    self:addTag('fireball')
    self.anim = Animation(Sprites.object.FIREBALL, 2, 5)
    self.body:setLinearVelocity(SPEED * direction, 0)
    self.timer = Timer()
    self.timer:after(LIFETIME, function() self:destroy() end)
    sounds.FIREBALL_SHOOT:play()
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
    end
end

function Fireball:destroy()
    sounds.FIREBALL_HIT:play()
    Object.destroy(self)
end

function Fireball:draw()
    self.anim:draw(self.body:getX(), self.body:getY(), 0, 1, 1, 8, 8)
end

function Fireball:getDrawOrder()
    return 2
end

return Fireball
