local Signal     = require 'modules.hump.signal'
local Timer      = require 'modules.hump.timer'
local Vector     = require 'modules.hump.vector'
local Constants  = require 'src.Constants'
local Container  = require 'src.Container'
local Particles  = require 'src.Particles'
local Apple      = require 'src.objects.Apple'
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

local sprites = {
    CURSOR = love.graphics.newImage('res/img/cursor.png'),
    CURSOR_DRAG = love.graphics.newImage('res/img/cursor_drag.png'),
    HEART = love.graphics.newImage('res/img/heart.png'),
    COIN = love.graphics.newImage('res/img/coin.png'),
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
    self.lives = 3
    self.money = 0
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

    for i = 1, 10 do
        self:spawnPet()
        self:spawnApple()
    end

    for i = 1, 50 do
        local x = math.random(32, Constants.GAME_WIDTH - 32)
        local y = math.random(32, Constants.GAME_HEIGHT - 32)
        Grass(self.container, x, y)
    end

    Boundary(self.container, 0, 0, 16, Constants.GAME_HEIGHT) -- left
    Boundary(self.container, Constants.GAME_WIDTH - 16, 0, 16, Constants.GAME_HEIGHT) -- right
    Boundary(self.container, 16, 0, Constants.GAME_WIDTH - 32, 16) -- top
    Boundary(self.container, 16, Constants.GAME_HEIGHT - 16, Constants.GAME_WIDTH - 32, 16) -- bottom

    self.selection = nil

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
end

function Game:spawnPet()
    local x = math.random(32, Constants.GAME_WIDTH - 32)
    local y = math.random(32, Constants.GAME_HEIGHT - 32)
    local pet = pets[math.random(1, #pets)]
    pet(self.container, x, y)
    self.dustParticles:setPosition(x, y)
    self.dustParticles:emit(2)
end

function Game:spawnApple()
    local x = math.random(32, Constants.GAME_WIDTH - 32)
    local y = math.random(32, Constants.GAME_HEIGHT - 32)
    Apple(self.container, x, y)
    self.dustParticles:setPosition(x, y)
    self.dustParticles:emit(2)
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

function Game:mousepressed(x, y)
    self.container:forEach(function(object)
        if object:hasTag('selectable') and object:contains(x, y) then
            object:select()
            self.selection = object
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

    for i = 1, self.lives do
        love.graphics.draw(sprites.HEART, 4 + (i - 1) * 11, 4)
    end
    love.graphics.draw(sprites.COIN, 4, 16 - self.moneyOffset)
    love.graphics.print(self.money, 19, 15 - self.moneyOffset)
end

return Game
