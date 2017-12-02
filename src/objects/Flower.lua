local Class = require 'modules.hump.class'
local Object = require 'src.Object'
local Timer = require 'modules.hump.timer'

local Flower = Class.new()
Flower:include(Object)

local RADIUS = 6
local SHAPE = love.physics.newCircleShape(RADIUS)

local sprites = {
    love.graphics.newImage('res/img/flower.png'),
    love.graphics.newImage('res/img/grass.png'),
}

function Flower:init(world, x, y)
    Object.init(self, world, x, y + RADIUS)
    self:addTag('flower')
    self.timer = Timer()
    self.shear = 0
    local type = math.random(1, #sprites)
    if type < 1 then
        self:addTag('pollen')
    end
    self.sprite = sprites[type]
    self:jostle(2)
end

function Flower:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'static')
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setSensor(true)
    fixture:setUserData(self)
    return body
end

function Flower:update(dt)
    Object.update(self, dt)
    self.timer:update(dt)
end

function Flower:jostle(vx)
    if math.abs(self.shear) < 0.1 then
        self.shear = vx / 32
        self.timer:clear()
        self.timer:tween(60, self, {shear = 0}, 'out-elastic')
    end
end

function Flower:draw()
    love.graphics.draw(self.sprite, self.body:getX(), self.body:getY() + RADIUS,
        0, 1, 1, 8, 16, self.shear)
end

return Flower
