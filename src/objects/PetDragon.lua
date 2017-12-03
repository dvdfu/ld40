local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Fireball = require 'src.objects.Fireball'
local Pet = require 'src.objects.Pet'
local Timer = require 'modules.hump.timer'

local PetDragon = Class.new()
PetDragon:include(Pet)

local DAMPING = 0.3
local FIREBALL_INTERVAL = 200
local SHAPE = love.physics.newCircleShape(6)
local SPRITE = love.graphics.newImage('res/img/pet/dragon.png')

function PetDragon:init(world, x, y)
    Pet.init(self, world, x, y)
    self:addTag('dragon')
    self.timer = Timer()
    self.timer:every(FIREBALL_INTERVAL, function() self:breathFire() end)
end

function PetDragon:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData(self)
    return body
end

function PetDragon:newAnimation()
    return Animation(SPRITE, 2, 10)
end

function PetDragon:update(dt)
    Pet.update(self, dt)
    self.timer:update(dt)
end

function PetDragon:breathFire()
    local world = self.body:getWorld()
    local fireball = Fireball(world, self.body:getX(), self.body:getY(), self.faceRight)
end

function PetDragon:draw()
    Pet.draw(self)
end

return PetDragon
