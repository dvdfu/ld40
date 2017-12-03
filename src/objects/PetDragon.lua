local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Fireball = require 'src.objects.Fireball'
local Pet = require 'src.objects.Pet'
local Timer = require 'modules.hump.timer'

local PetDragon = Class.new()
PetDragon:include(Pet)

local DAMPING = 0.3
local FIREBALL_INTERVAL = 120
local SHAPE = love.physics.newCircleShape(6)
local SPRITE = love.graphics.newImage('res/img/pet/dragon.png')

function PetDragon:init(container, x, y)
    Pet.init(self, container, x, y)
    self:addTag('dragon')
    self.anim = Animation(SPRITE, 2, 10)
    self.timer = Timer()
    self.timer:every(FIREBALL_INTERVAL, function() self:breathFire() end)
end

function PetDragon:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    body:setUserData(self)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
    return body
end

function PetDragon:newAnimation()
    return Animation(SPRITE, 2, 10)
end

function PetDragon:update(dt)
    Pet.update(self, dt)
    if not self:isSelected() then
        self.timer:update(dt)
    end
end

function PetDragon:breathFire()
    local x = self.body:getX() + (self.faceRight and 8 or -8)
    local y = self.body:getY() + 1
    local fireball = Fireball(self.container, x, y, self.faceRight)
    self.faceRight = not self.faceRight
    self:squish(2)
end

function PetDragon:draw()
    Pet.draw(self)
end

return PetDragon
