local Vector     = require 'modules.hump.vector'
local Constants  = require 'src.Constants'
local Particles  = require 'src.Particles'
local Apple      = require 'src.objects.Apple'
local PetAmanita = require 'src.objects.PetAmanita'
local PetChin    = require 'src.objects.PetChin'
local PetDasher  = require 'src.objects.PetDasher'
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
    PetMollusk,
}

function Game:init()
end

function Game:enter()
    self.world = love.physics.newWorld()
    self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    self.lives = 3

    self.pets = {}
    self.selectedPet = nil
    for i = 1, 10 do
        local pet = pets[math.random(1, #pets)]
        table.insert(self.pets, pet(self.world, i * 20, i * 10))
    end

    self.apples = {}
    for i = 1, 10 do
        table.insert(self.apples, Apple(self.world, i * 10, i * 20))
    end

    self.walls = {
        Wall(self.world, 0, 0, 4, Constants.GAME_HEIGHT),
        Wall(self.world, Constants.GAME_WIDTH - 4, 0, 4, Constants.GAME_HEIGHT),
        Wall(self.world, 0, 0, Constants.GAME_WIDTH, 4),
        Wall(self.world, 0, Constants.GAME_HEIGHT - 4, Constants.GAME_WIDTH, 4),
    }

    self.appleParticles = Particles.newApple()
    self.dustParticles = Particles.newDust()

    self.mousePosition = Vector(0, 0)
end

function Game:update(dt)
    if self.selectedPet then
        self.selectedPet:drag(self.mousePosition:unpack())
    end

    self.world:update(dt)
    self.appleParticles:update(dt)
    self.dustParticles:update(dt)
    for i, pet in pairs(self.pets) do
        if pet:isDestroyed() then
            pet:onDelete()
            self.pets[i] = nil
            self:loseLife()
        else
            pet:update(dt)
        end
    end
    for i, apple in pairs(self.apples) do
        if apple:isDestroyed() then
            local x, y = apple:getPosition():unpack()
            apple:onDelete()
            self.appleParticles:setPosition(x, y)
            self.appleParticles:emit(10)
            self.apples[i] = nil
        else
            apple:update(dt)
        end
    end
end

function Game:loseLife()
    if self.lives > 0 then
        self.lives = self.lives - 1
    else
    end
end

function Game:mousepressed(x, y)
    for _, pet in pairs(self.pets) do
        if pet:contains(x, y) then
            pet:select()
            self.selectedPet = pet
            return
        end
    end
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
    if self.selectedPet then
        if dx * dx + dy * dy > 40 then
            self.dustParticles:setPosition(self.selectedPet:getPosition():unpack())
            self.dustParticles:emit(1)
        end
    end
end

function Game:draw()
    love.graphics.draw(self.dustParticles)
    for _, apple in pairs(self.apples) do
        apple:draw()
    end
    for _, pet in pairs(self.pets) do
        pet:draw()
    end
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
