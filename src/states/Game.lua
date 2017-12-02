local Constants = require 'src.Constants'
local Pet = require 'src.objects.PetChin'
local Vector = require 'modules.hump.vector'
local Wall = require 'src.objects.Wall'

local sprites = {
    CURSOR = love.graphics.newImage('res/img/cursor.png'),
    HEART = love.graphics.newImage('res/img/heart.png'),
}

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

function Game:init()
end

function Game:enter()
    self.world = love.physics.newWorld()
    self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    self.lives = 3

    self.pets = {}
    self.selectedPet = nil
    for i = 1, 10 do
        table.insert(self.pets, Pet(self.world, i * 10, i * 10))
    end

    self.walls = {
        Wall(self.world, 0, 0, 4, Constants.GAME_HEIGHT),
        Wall(self.world, Constants.GAME_WIDTH - 4, 0, 4, Constants.GAME_HEIGHT),
        Wall(self.world, 0, 0, Constants.GAME_WIDTH, 4),
        Wall(self.world, 0, Constants.GAME_HEIGHT - 4, Constants.GAME_WIDTH, 4),
    }

    self.mousePosition = Vector(0, 0)
end

function Game:update(dt)
    self.world:update(dt)
    for i, pet in pairs(self.pets) do
        if pet:isDead() then
            self.pets[i] = nil
            self:loseLife()
        else
            pet:update(dt)
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

function Game:mousemoved(x, y)
    self.mousePosition.x = x
    self.mousePosition.y = y
    if self.selectedPet then
        self.selectedPet:drag(x, y)
    end
end

function Game:draw()
    for _, pet in pairs(self.pets) do
        pet:draw()
    end

    for i = 1, self.lives do
        love.graphics.draw(sprites.HEART, 4 + (i - 1) * 11, 4)
    end
    love.graphics.draw(sprites.CURSOR, self.mousePosition.x, self.mousePosition.y, 0, 1, 1, 4, 1)
end

return Game
