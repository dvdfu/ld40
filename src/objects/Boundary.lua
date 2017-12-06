local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Object = require 'src.Object'
local Sprites = require 'src.Sprites'
local Vector = require 'modules.hump.vector'

local Boundary = Class.new()
Boundary:include(Object)

function Boundary:init(container, x, y, w, h)
    self.size = Vector(w, h)
    Object.init(self, container, x + w / 2, y + h / 2)
    self.anim = Animation(Sprites.object.GROUND, 4, 10)
end

function Boundary:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'static')
    body:setUserData(self)
    local shape = love.physics.newRectangleShape(self.size:unpack())
    local fixture = love.physics.newFixture(body, shape)
    return body
end

function Boundary:update(dt)
    self.anim:update(dt)
end

function Boundary:draw()
    local x = self.body:getX() - self.size.x / 2
    local y = self.body:getY() - self.size.y / 2
    for i = 0, self.size.x - 1, 16 do
        for j = 0, self.size.y - 1, 16 do
            self.anim:draw(x + i, y + j)
        end
    end
end

return Boundary
