local Class      = require 'modules.hump.class'
local Timer      = require 'modules.hump.timer'
local Animation  = require 'src.Animation'
local PetAmanita = require 'src.objects.PetAmanita'
local PetChin    = require 'src.objects.PetChin'
local PetDasher  = require 'src.objects.PetDasher'
local PetDragon  = require 'src.objects.PetDragon'
local PetLumpy   = require 'src.objects.PetLumpy'
local PetFerro   = require 'src.objects.PetFerro'
local PetMollusk = require 'src.objects.PetMollusk'
local Selectable = require 'src.objects.Selectable'

local Egg = Class.new()
Egg:include(Selectable)

local DAMPING = 1
local RADIUS = 6
local SHAPE = love.physics.newCircleShape(RADIUS)
local SPRITE = love.graphics.newImage('res/img/egg.png')

local pets = {
    PetAmanita,
    PetChin,
    PetDasher,
    PetDragon,
    PetLumpy,
    PetFerro,
    PetMollusk,
}

function Egg:init(container, x, y)
    Selectable.init(self, container, x, y)
    self:addTag('egg')
    self.anim = Animation(SPRITE, 2, 8)
    self.timer = Timer()
    self.timer:after(180, function() self:open() end)
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

function Egg:open()
    local x, y = self.body:getPosition()
    local type = math.random(1, #pets)
    local pet = pets[type]
    if type == 1 then
        pet(self.container, x, y)
    end
    pet(self.container, x, y)
    self:destroy()
end

function Egg:draw()
    self.anim:draw(self.body:getX(), self.body:getY(), 0, 1, 1, 8, 8)
end

function Egg:getDrawOrder()
    return 2
end

return Egg
