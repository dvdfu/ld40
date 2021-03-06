local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Object = require 'src.Object'
local Sprites = require 'src.Sprites'
local Timer = require 'modules.hump.timer'

local Grass = Class.new()
Grass:include(Object)

local RADIUS = 6
local SHAPE = love.physics.newCircleShape(RADIUS)

function Grass:init(container, x, y)
    Object.init(self, container, x, y - RADIUS)
    self:addTag('grass')
    self.timer = Timer()
    self.shear = 0
    self.anim = Animation(Sprites.object.GRASS, 3, 1)
    self.anim:update(math.random(1, 3))
end

function Grass:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'static')
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setSensor(true)
    return body
end

function Grass:update(dt)
    Object.update(self, dt)
    self.timer:update(dt)
end

function Grass:jostle(vx)
    if math.abs(self.shear) < 0.01 then
        if vx > 0.5 then self.shear = 0.5 end
        if vx < -0.5 then self.shear = -0.5 end
        self.timer:clear()
        self.timer:tween(60, self, {shear = 0}, 'out-elastic')
    end
end

function Grass:draw()
    self.anim:draw(self.body:getX(), self.body:getY() + RADIUS, 0, 1, 1, 8, 16, self.shear)
end

function Grass:getDrawOrder()
    return 1
end

return Grass
