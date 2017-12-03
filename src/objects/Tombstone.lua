local Class = require 'modules.hump.class'
local Object = require 'src.Object'
local Timer = require 'modules.hump.timer'

local Tombstone = Class.new()
Tombstone:include(Object)

local RADIUS = 6
local SHAPE = love.physics.newCircleShape(RADIUS)
local SPRITE = love.graphics.newImage('res/img/tombstone.png')

function Tombstone:init(container, x, y)
    Object.init(self, container, x, y)
    self:addTag('solid')
    self:addTag('tombstone')
    self.offset = 16
    self.xScale = 1 / 2
    self.yScale = 2
    self.timer = Timer()
    self.timer:tween(30, self, {
        offset = 0,
        xScale = 1,
        yScale = 1,
    }, 'in-bounce')
end

function Tombstone:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'static')
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData(self)
    return body
end

function Tombstone:update(dt)
    self.timer:update(dt)
end

function Tombstone:draw()
    local x = self.body:getX()
    local y = self.body:getY() - self.offset + 8
    love.graphics.draw(SPRITE, x, y, 0, self.xScale, self.yScale, 8, 16)
end

function Tombstone:getDrawOrder()
    return 1
end

return Tombstone
