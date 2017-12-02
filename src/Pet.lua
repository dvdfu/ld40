local Class = require 'modules.hump.class'
local Animation = require 'src.Animation'
local Vector = require 'modules.hump.vector'

local Pet = Class.new()

local sprite = love.graphics.newImage('assets/pet/amanita.png')

function Pet:init(x, y)
    self.pos = Vector(x, y)
    self.anim = Animation(sprite, 2, 10)
end

function Pet:update(dt)
    self.anim:update(dt)
end

function Pet:draw()
    self.anim:draw(self.pos:unpack())
end

return Pet
