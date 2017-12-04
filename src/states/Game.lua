local Signal     = require 'modules.hump.signal'
local Timer      = require 'modules.hump.timer'
local Vector     = require 'modules.hump.vector'
local Constants  = require 'src.Constants'
local Container  = require 'src.Container'
local Particles  = require 'src.Particles'
local Apple      = require 'src.objects.Apple'
local AppleCrate = require 'src.objects.AppleCrate'
local Boundary   = require 'src.objects.Boundary'
local Grass      = require 'src.objects.Grass'
local PetAmanita = require 'src.objects.PetAmanita'
local PetChin    = require 'src.objects.PetChin'
local PetDasher  = require 'src.objects.PetDasher'
local PetDragon  = require 'src.objects.PetDragon'
local PetLumpy   = require 'src.objects.PetLumpy'
local PetFerro   = require 'src.objects.PetFerro'
local PetMollusk = require 'src.objects.PetMollusk'
local Tombstone  = require 'src.objects.Tombstone'

local Game = {}

local NEXT_PET_TIME = 180
local NEXT_PET_TIME_MAX = 540

local sprites = {
    CURSOR = love.graphics.newImage('res/img/cursor.png'),
    CURSOR_DRAG = love.graphics.newImage('res/img/cursor_drag.png'),
    HEART = love.graphics.newImage('res/img/heart.png'),
    COIN = love.graphics.newImage('res/img/coin.png'),
    PET = love.graphics.newImage('res/img/pet.png'),
}

local pets = {
    PetAmanita,
    PetChin,
    PetDasher,
    PetDragon,
    PetLumpy,
    PetFerro,
    PetMollusk,
}

function Game:init()
    local font = love.graphics.newFont('res/font/redalert.ttf', 13)
    love.graphics.setFont(font)
end

function Game:enter()
    self.lives = 10
    self.money = 10
    self.pets = 0
    self.moneyOffset = 0
    self.moneyOffsetTimer = Timer()

    self.container = Container(function(object)
        local x, y = object:getPosition():unpack()
        if object == self.selection then
            object:unselect()
            self.selection = nil
        end
        if object:hasTag('apple') then
            self.appleParticles:setPosition(x, y)
            self.appleParticles:emit(10)
        elseif object:hasTag('pet') then
            self.dustParticles:setPosition(x, y)
            self.dustParticles:emit(2)
            if not object:hasTag('lumpy') then
                Tombstone(self.container, x, y)
            end
            self:onLoseLife()
        elseif object:hasTag('fireball') then
            self.dustParticles:setPosition(x, y)
            self.dustParticles:emit(2)
        end
    end)

    self.appleParticles = Particles.newApple()
    self.dustParticles = Particles.newDust()

    for i = 1, 50 do
        local x = math.random(32, Constants.GAME_WIDTH - 32)
        local y = math.random(32, Constants.GAME_HEIGHT - 32)
        Grass(self.container, x, y)
    end

    Boundary(self.container, 0, 0, 16, Constants.GAME_HEIGHT) -- left
    Boundary(self.container, Constants.GAME_WIDTH - 16, 0, 16, Constants.GAME_HEIGHT) -- right
    Boundary(self.container, 16, 0, Constants.GAME_WIDTH - 32, 16) -- top
    Boundary(self.container, 16, Constants.GAME_HEIGHT - 16, Constants.GAME_WIDTH - 32, 16) -- bottom

    AppleCrate(self.container, Constants.GAME_WIDTH / 2, Constants.GAME_HEIGHT - 48)

    self.selection = nil

    self.nextPetTimer = 0
    self.nextPetTimerMax = NEXT_PET_TIME
    self.nextPet = math.random(1, #pets)

    Signal.register('payout', function() self:onPayout() end)
end

function Game:update(dt)
    if self.selection then
        self.selection:drag(mousePosition:unpack())
    end
    self.appleParticles:update(dt)
    self.dustParticles:update(dt)
    self.container:update(dt)
    self.moneyOffsetTimer:update(dt)

    if self.nextPetTimer > 1 then
        self.nextPetTimer = self.nextPetTimer - 1
    else
        self:spawnPet(pets[self.nextPet])
        if self.nextPet == 1 then
            self:spawnPet(pets[self.nextPet])
        end
        if self.nextPetTimerMax < NEXT_PET_TIME_MAX then
            self.nextPetTimerMax = self.nextPetTimerMax + 60
        else
            self.nextPetTimerMax = NEXT_PET_TIME_MAX
        end
        self.nextPetTimer = self.nextPetTimerMax
        self.nextPet = math.random(1, #pets)
    end
end

function Game:spawnPet(pet)
    local x = math.random(32, Constants.GAME_WIDTH - 32)
    local y = math.random(32, Constants.GAME_HEIGHT - 32)
    pet(self.container, x, y)
    self.dustParticles:setPosition(x, y)
    self.dustParticles:emit(2)
    self.pets = self.pets + 1
end

function Game:onLoseLife()
    if self.lives > 0 then
        self.lives = self.lives - 1
    else
    end
end

function Game:onPayout()
    self.money = self.money + 1
    self.moneyOffset = 4
    self.moneyOffsetTimer:clear()
    self.moneyOffsetTimer:tween(10, self, {moneyOffset = 0}, 'out-quad')
end

function Game:buyLife()
    if self.money >= 50 then
        self.money = self.money - 50
        self.lives = self.lives + 1
    end
end

function Game:buyApple(crate)
    if self.money >= 3 then
        crate:onClick()
        self.money = self.money - 3
        self.moneyOffset = -4
        self.moneyOffsetTimer:clear()
        self.moneyOffsetTimer:tween(10, self, {moneyOffset = 0}, 'out-quad')
        if self.selection then self.selection:unselect() end
        local apple = Apple(self.container, mousePosition.x, mousePosition.y)
        apple:select()
        self.selection = apple
        self.dustParticles:setPosition(mousePosition.x, mousePosition.y)
        self.dustParticles:emit(2)
    end
end

function Game:mousepressed(x, y)
    self.container:forEach(function(object)
        if object:hasTag('selectable') and object:contains(x, y) then
            object:select()
            self.selection = object
            return
        elseif object:hasTag('crate') and object:contains(x, y) then
            self:buyApple(object)
            return
        end
    end)
end

function Game:mousereleased(x, y)
    if self.selection then
        self.selection:unselect()
        self.selection = nil
    end
end

function Game:draw()
    self.container:draw()
    love.graphics.draw(self.dustParticles)
    love.graphics.draw(self.appleParticles)

    love.graphics.setColor(131, 131, 72)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', 0, 0, Constants.GAME_WIDTH, 15)
    love.graphics.setColor(255, 255, 255)

    local x = 16
    love.graphics.draw(sprites.HEART, x, 2)
    love.graphics.print(self.lives, x + 15, 1)

    x = x + 32
    love.graphics.draw(sprites.COIN, x, 2 - self.moneyOffset)
    love.graphics.print(self.money, x + 15, 1 - self.moneyOffset)
end

return Game
