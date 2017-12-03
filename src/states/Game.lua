local Vector     = require 'modules.hump.vector'
local Constants  = require 'src.Constants'
local Container  = require 'src.Container'
local Particles  = require 'src.Particles'
local Apple      = require 'src.objects.Apple'
local Flower     = require 'src.objects.Flower'
local PetAmanita = require 'src.objects.PetAmanita'
local PetChin    = require 'src.objects.PetChin'
local PetDasher  = require 'src.objects.PetDasher'
local PetDragon  = require 'src.objects.PetDragon'
local PetMollusk = require 'src.objects.PetMollusk'
local Wall       = require 'src.objects.Wall'

local function beginContact(a, b, coll)
    local objA = a:getUserData()
    local objB = b:getUserData()
    objA:collide(coll, objB)
    objB:collide(coll, objA)
end
local function endContact(a, b, coll) end
local function preSolve(a, b, coll) end
local function postSolve(a, b, coll, normalimpulse, tangentimpulse) end

local Game = {}

local sprites = {
    CURSOR = love.graphics.newImage('res/img/cursor.png'),
    CURSOR_DRAG = love.graphics.newImage('res/img/cursor_drag.png'),
    HEART = love.graphics.newImage('res/img/heart.png'),
}

local pets = {
    PetAmanita,
    PetChin,
    PetDasher,
    PetDragon,
    PetMollusk,
}

function Game:init()
end

function Game:enter()
    self.world = love.physics.newWorld()
    self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    self.lives = 3

    self.objects = Container(function(object)
        if object:hasTag('apple') then
            local x, y = object:getPosition():unpack()
            self.appleParticles:setPosition(x, y)
            self.appleParticles:emit(10)
        elseif object:hasTag('pet') then
            self:loseLife()
        end
    end)

    for i = 1, 10 do
        local pet = pets[math.random(1, #pets)]
        local x = math.random(8, Constants.GAME_WIDTH - 8)
        local y = math.random(8, Constants.GAME_HEIGHT - 8)
        self.objects:add(pet(self.world, x, y))
    end

    for i = 1, 10 do
        local x = math.random(8, Constants.GAME_WIDTH - 8)
        local y = math.random(8, Constants.GAME_HEIGHT - 8)
        self.objects:add(Apple(self.world, x, y))
    end

    for i = 1, 20 do
        local x = math.random(8, Constants.GAME_WIDTH - 8)
        local y = math.random(8, Constants.GAME_HEIGHT - 8)
        self.objects:add(Flower(self.world, x, y))
    end

    self.objects:add(Wall(self.world, 0, 0, 4, Constants.GAME_HEIGHT))
    self.objects:add(Wall(self.world, Constants.GAME_WIDTH - 4, 0, 4, Constants.GAME_HEIGHT))
    self.objects:add(Wall(self.world, 0, 0, Constants.GAME_WIDTH, 4))
    self.objects:add(Wall(self.world, 0, Constants.GAME_HEIGHT - 4, Constants.GAME_WIDTH, 4))

    self.selectedPet = nil

    self.appleParticles = Particles.newApple()
    self.dustParticles = Particles.newDust()

    self.mousePosition = Vector(0, 0)
end

function Game:update(dt)
    if self.selectedPet then
        self.selectedPet:drag(self.mousePosition:unpack())
        if self.selectedPet:getLinearVelocity():len2() > 40 then
            self.dustParticles:setPosition(self.selectedPet:getPosition():unpack())
            self.dustParticles:emit(1)
        end
    end
    self.appleParticles:update(dt)
    self.dustParticles:update(dt)
    self.objects:update(dt)
    self.world:update(dt)
end

function Game:loseLife()
    if self.lives > 0 then
        self.lives = self.lives - 1
    else
    end
end

function Game:mousepressed(x, y)
    self.objects:forEach(function(object)
        if object:hasTag('pet') and object:contains(x, y) then
            object:select()
            self.selectedPet = object
            return
        end
    end)
end

function Game:mousereleased(x, y)
    if self.selectedPet then
        self.selectedPet:unselect()
        self.selectedPet = nil
    end
end

function Game:mousemoved(x, y, dx, dy)
    self.mousePosition.x = x
    self.mousePosition.y = y
end

function Game:draw()
    self.objects:draw()
    love.graphics.draw(self.dustParticles)
    love.graphics.draw(self.appleParticles)

    for i = 1, self.lives do
        love.graphics.draw(sprites.HEART, 4 + (i - 1) * 11, 4)
    end
    if self.selectedPet then
        love.graphics.draw(sprites.CURSOR_DRAG, self.mousePosition.x, self.mousePosition.y, 0, 1, 1, 4, 1)
    else
        love.graphics.draw(sprites.CURSOR, self.mousePosition.x, self.mousePosition.y, 0, 1, 1, 4, 1)
    end
end

return Game
