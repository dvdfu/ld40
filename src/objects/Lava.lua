local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Object = require 'src.Object'
local Vector = require 'modules.hump.vector'

local Lava = Class.new()
Lava:include(Object)

local SPRITE = love.graphics.newImage('res/img/lava.png')

function Lava:init(container, x, y, w, h)
    self.size = Vector(w, h)
    Object.init(self, container, x + w / 2, y + h / 2)
    self:addTag('lava')
    self.anim = Animation(SPRITE, 4, 10)
end

function Lava:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'static')
    local shape = love.physics.newRectangleShape(self.size:unpack())
    local fixture = love.physics.newFixture(body, shape)
    fixture:setSensor(true)
    fixture:setUserData(self)
    return body
end

function Lava:update(dt)
    self.anim:update(dt)
end

function Lava:draw()
    local x = self.body:getX() - self.size.x / 2
    local y = self.body:getY() - self.size.y / 2
    for i = 0, self.size.x - 1, 16 do
        for j = 0, self.size.y - 1, 16 do
            self.anim:draw(x + i, y + j)
        end
    end
end

return Lava
