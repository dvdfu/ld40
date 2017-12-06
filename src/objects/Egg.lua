local Class = require 'modules.hump.class'
local Timer = require 'modules.hump.timer'
local Animation = require 'src.Animation'
local Selectable = require 'src.objects.Selectable'
local Sprites = require 'src.Sprites'

local Egg = Class.new()
Egg:include(Selectable)

local DAMPING = 1
local RADIUS = 6
local SHAPE = love.physics.newCircleShape(RADIUS)

function Egg:init(container, x, y)
    Selectable.init(self, container, x, y)
    self:addTag('egg')
    self.anim = Animation(Sprites.object.EGG, 2, 8)
    self.timer = Timer()
    self.timer:after(180, function() self:destroy() end)
end

function Egg:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    return body
end

function Egg:update(dt)
    Selectable.update(self, dt)
    self.anim:update(dt)
    self.timer:update(dt)
end

function Egg:draw()
    local x, y = self.body:getPosition()
    self.anim:draw(x, y, 0, 1, 1, 8, 8)
end

function Egg:getDrawOrder()
    return 2
end

return Egg
