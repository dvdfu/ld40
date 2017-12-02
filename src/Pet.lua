local Class = require 'modules.hump.class'
local Animation = require 'src.Animation'
local Timer = require 'modules.hump.timer'
local Vector = require 'modules.hump.vector'

local Pet = Class.new()

local sprite = love.graphics.newImage('assets/pet/amanita.png')

function Pet:init(x, y)
    self.pos = Vector(x, y)
    self.vel = Vector(0, 0)
    self.anchor = Vector(x, y)
    self.offset = Vector(8, 8)
    self.scale = Vector(1, 1)
    self.anim = Animation(sprite, 2, 10)
    self.bodyRadius = 8

    self.wanderRadius = 24
    self.faceRight = true
    self.selected = false
    self.timer = Timer()
end

function Pet:update(dt)
    if not self.selected then
        self.pos = self.pos + self.vel
        self.vel = self.vel * 0.9
    end

    local animSpeed = self.selected and 2 or 1
    self.anim:update(dt * animSpeed)
    self.timer:update(dt)
end

function Pet:contains(x, y)
    local delta = Vector(x, y) - self.pos
    return delta:len2() < self.bodyRadius * self.bodyRadius
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
    self.vel.x = x - self.pos.x
    self.vel.y = y - self.pos.y
    if self.vel.x > 1 then self.faceRight = true end
    if self.vel.x < -1 then self.faceRight = false end
    self.pos.x = x
    self.pos.y = y
    self.anchor.x = x
    self.anchor.y = y
end

function Pet:draw()
    local direction = self.faceRight and 1 or -1
    self.anim:draw(self.pos.x, self.pos.y, 0, self.scale.x * direction, self.scale.y, self.offset.x, self.offset.y)

    -- love.graphics.circle('line', self.anchor.x, self.anchor.y, self.wanderRadius)
end

return Pet
