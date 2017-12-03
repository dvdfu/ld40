local Signal     = require 'modules.hump.signal'
local Timer      = require 'modules.hump.timer'
local Vector     = require 'modules.hump.vector'
local Constants  = require 'src.Constants'
local Container  = require 'src.Container'
local Particles  = require 'src.Particles'
local Apple      = require 'src.objects.Apple'
local Grass      = require 'src.objects.Grass'
local Lava       = require 'src.objects.Lava'
local PetAmanita = require 'src.objects.PetAmanita'
local PetChin    = require 'src.objects.PetChin'
local PetDasher  = require 'src.objects.PetDasher'
local PetDragon  = require 'src.objects.PetDragon'
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
            self.dustParticles:emit(1)
            Tombstone(self.container, x, y)
            self:onLoseLife()
        elseif object:hasTag('fireball') then
            self.dustParticles:setPosition(x, y)
            self.dustParticles:emit(1)
        end
    end)

    for i = 1, 10 do
        local pet = pets[math.random(1, #pets)]
        local x = math.random(32, Constants.GAME_WIDTH - 32)
        local y = math.random(32, Constants.GAME_HEIGHT - 32)
        pet(self.container, x, y)
    end

    for i = 1, 10 do
        local x = math.random(32, Constants.GAME_WIDTH - 32)
        local y = math.random(32, Constants.GAME_HEIGHT - 32)
        Apple(self.container, x, y)
    end

    for i = 1, 50 do
        local x = math.random(32, Constants.GAME_WIDTH - 32)
        local y = math.random(32, Constants.GAME_HEIGHT - 32)
        Grass(self.container, x, y)
    end

    Lava(self.container, 0, 0, 16, Constants.GAME_HEIGHT) -- left
    Lava(self.container, Constants.GAME_WIDTH - 16, 0, 16, Constants.GAME_HEIGHT) -- right
    Lava(self.container, 16, 0, Constants.GAME_WIDTH - 32, 16) -- top
    Lava(self.container, 16, Constants.GAME_HEIGHT - 16, Constants.GAME_WIDTH - 32, 16) -- bottom


    self.appleParticles = Particles.newApple()
    self.dustParticles = Particles.newDust()

    self.selection = nil
    self.mousePosition = Vector(0, 0)

    Signal.register('payout', function() self:onPayout() end)
end

function Game:update(dt)
    if self.selection then
        self.selection:drag(self.mousePosition:unpack())
        if self.selection:getLinearVelocity():len2() > 100 then
            self.dustParticles:setPosition(self.selection:getPosition():unpack())
            self.dustParticles:emit(1)
        end
    end
    self.appleParticles:update(dt)
    self.dustParticles:update(dt)
    self.container:update(dt)
    self.moneyOffsetTimer:update(dt)
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

function Game:mousemoved(x, y, dx, dy)
    self.mousePosition.x = x
    self.mousePosition.y = y
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

    if self.selection then
        love.graphics.draw(sprites.CURSOR_DRAG, self.mousePosition.x, self.mousePosition.y, 0, 1, 1, 4, 1)
    else
        love.graphics.draw(sprites.CURSOR, self.mousePosition.x, self.mousePosition.y, 0, 1, 1, 4, 1)
    end
end

return Game
