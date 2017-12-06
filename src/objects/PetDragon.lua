local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Fireball = require 'src.objects.Fireball'
local Pet = require 'src.objects.Pet'
local Sounds = require 'src.Sounds'
local Sprites = require 'src.Sprites'
local Timer = require 'modules.hump.timer'

local PetDragon = Class.new()
PetDragon:include(Pet)

local FIREBALL_INTERVAL = 240
local SHAPE = love.physics.newCircleShape(6)

function PetDragon:init(container, x, y)
    Pet.init(self, container, x, y, {
        appleEater = true,
        immuneFireball = true,
        payout = 2,
        sound = Sounds.pet.DRAGON,
    })
    self:addTag('dragon')
    self.anim = Animation(Sprites.pet.dragon.IDLE, 2, 10)
    self.fireballSpawnTimer = Timer()
    self.fireballSpawnTimer:every(FIREBALL_INTERVAL, function()
        self:breathFire()
    end)
end

function PetDragon:onCreateBody(body)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData('body')
end

function PetDragon:update(dt)
    Pet.update(self, dt)
    if not self:isSelected() then
        self.fireballSpawnTimer:update(dt)
    end
end

function PetDragon:breathFire()
    local x = self.body:getX() + self.direction * 8
    local y = self.body:getY() + 1
    local fireball = Fireball(self.container, x, y, self.direction)
    self.direction = -self.direction
    self:squish()
end

return PetDragon
