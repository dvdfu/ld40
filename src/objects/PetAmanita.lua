local Animation = require 'src.Animation'
local Class = require 'modules.hump.class'
local Particles = require 'src.Particles'
local Timer = require 'modules.hump.timer'
local WalkablePet = require 'src.objects.WalkablePet'

local PetAmanita = Class.new()
PetAmanita:include(WalkablePet)

local DAMPING = 0.3
local SHAPE = love.physics.newCircleShape(6)
local SPRITE = love.graphics.newImage('res/img/pet/amanita.png')

function PetAmanita:init(container, x, y)
    WalkablePet.init(self, container, x, y)
    self:addTag('amanita')
    self.tears = Particles.newTears()
    self.tearsTimer = Timer()
    self.tearsTimer:every(10, function()
        local x, y = self.body:getPosition()
        self.tears:setPosition(x, y - 4)
        self.tears:emit(1)
    end)
end

function PetAmanita:newBody(world, x, y)
    local body = love.physics.newBody(world, x, y, 'dynamic')
    body:setLinearDamping(DAMPING, DAMPING)
    local fixture = love.physics.newFixture(body, SHAPE)
    fixture:setUserData(self)
    return body
end

function PetAmanita:newAnimation()
    return Animation(SPRITE, 2, 10)
end

function PetAmanita:update(dt)
    WalkablePet.update(self, dt)
    self.tears:update(dt)
    self.tearsTimer:update(dt)
end

function PetAmanita:draw()
    WalkablePet.draw(self)
    love.graphics.draw(self.tears)
end


return PetAmanita
