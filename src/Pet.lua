local Class = require 'modules.hump.class'
local Animation = require 'src.Animation'
local Vector = require 'modules.hump.vector'

local Pet = Class.new()

local sprite = love.graphics.newImage('assets/pet/amanita.png')

function Pet:init(x, y)
    self.pos = Vector(x, y)
    self.offset = Vector(8, 8)
    self.anim = Animation(sprite, 2, 10)
    self.radius = 8

    self.faceRight = true
    self.selected = false
end

function Pet:update(dt)
    local animSpeed = self.selected and 2 or 1
    self.anim:update(dt * animSpeed)
end

function Pet:contains(x, y)
    local delta = Vector(x, y) - self.pos
    return delta:len2() < self.radius * self.radius
end

function Pet:isSelected()
    return self.selected
end

function Pet:select()
    self.selected = true
end

function Pet:unselect()
    self.selected = false
end

function Pet:move(x, y)
    if x > self.pos.x + 2 then self.faceRight = true end
    if x < self.pos.x - 2 then self.faceRight = false end
    self.pos.x = x
    self.pos.y = y
end

function Pet:draw()
    local xScale = self.faceRight and 1 or -1
    self.anim:draw(self.pos.x, self.pos.y, 0, xScale, 1, self.offset.x, self.offset.y)
end

return Pet
