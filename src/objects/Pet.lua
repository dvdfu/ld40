local Animation = require 'src.Animation'
local Constants = require 'src.Constants'
local Class = require 'modules.hump.class'
local Object = require 'src.Object'
local Timer = require 'modules.hump.timer'
local Vector = require 'modules.hump.vector'

local Pet = Class.new()
Pet:include(Object)

local DAMPING = 1
local SHAPE = love.physics.newRectangleShape(16, 16)
local SPRITE = love.graphics.newImage('res/img/pet/default.png')
local SPRITE_OFFSET = Vector(8, 8)

function Pet:init(world, x, y)
    Object.init(self, world, x, y)
    self:addTag('pet')
    self.anim = self:newAnimation()
    self.scale = Vector(1, 1)
    self.timer = Timer()
    self.faceRight = true
    self.selected = false
end

function Pet:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData(self)
    return body
end

function Pet:newAnimation()
    return Animation(SPRITE, 1, 1)
end

function Pet:update(dt)
    local vx, vy = self.body:getLinearVelocity()
    if vx > 1 then self.faceRight = true end
    if vx < -1 then self.faceRight = false end

    local animSpeed = self.selected and 2 or 1
    self.anim:update(dt * animSpeed)
    self.timer:update(dt)
end

function Pet:contains(x, y)
    return SHAPE:testPoint(self.body:getX(), self.body:getY(), 0, x, y)
end

function Pet:isSelected()
    return self.selected
end

function Pet:select()
    self.selected = true
    self.scale.x = 1.6
    self.scale.y = 1 / 1.6
    self.timer:clear()
    self.timer:tween(60, self.scale, {x = 1, y = 1}, 'out-elastic')
end

function Pet:unselect()
    self.selected = false
end

function Pet:drag(x, y)
    self.body:setLinearVelocity(x - self.body:getX(), y - self.body:getY())
end

function Pet:draw()
    local direction = self.faceRight and 1 or -1
    self.anim:draw(
        self.body:getX(), self.body:getY(), 0,
        self.scale.x * direction, self.scale.y,
        SPRITE_OFFSET.x, SPRITE_OFFSET.y)

    -- love.graphics.setFont(Constants.FONTS.REDALERT)
    -- love.graphics.printf('meep', self.body:getX() - 50, self.body:getY() - 20, 100, 'center')
end

return Pet
