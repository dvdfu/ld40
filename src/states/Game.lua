local Gamestate  = require 'modules.hump.gamestate'
local Signal     = require 'modules.hump.signal'
local Timer      = require 'modules.hump.timer'
local Vector     = require 'modules.hump.vector'
local Constants  = require 'src.Constants'
local Container  = require 'src.Container'
local Particles  = require 'src.Particles'
local Apple      = require 'src.objects.Apple'
local AppleCrate = require 'src.objects.AppleCrate'
local Boundary   = require 'src.objects.Boundary'
local Egg        = require 'src.objects.Egg'
local Grass      = require 'src.objects.Grass'
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

local sounds = {
    POP = love.audio.newSource('res/sfx/pop.mp3'),
    THUD_1 = love.audio.newSource('res/sfx/thud1.mp3'),
    DIE = love.audio.newSource('res/sfx/die.wav'),
}

function Game:init()
    local font = love.graphics.newFont('res/font/redalert.ttf', 13)
    love.graphics.setFont(font)

    Signal.register('payout', function() self:onPayout() end)
end

function Game:enter()
    self.lives = 1
    self.money = 10
    self.pets = 0
    self.stats = {
        totalPets = 0,
        totalMoney = 0,
        time = 0,
    }
    self.moneyOffset = 0
    self.moneyOffsetTimer = Timer()
    self.overlayPos = 1
    self.overlayTimer = Timer()
    self.overlayTimer:tween(30, self, {overlayPos = 0}, 'in-cubic')

    self.appleParticles = Particles.newApple()
    self.dustParticles = Particles.newDust()

    self.container = Container(function(object)
        local x, y = object:getPosition():unpack()
        if object == self.selection then
            object:unselect()
            self.selection = nil
        end
        if object:hasTag('apple') then
            self.appleParticles:setPosition(x, y)
            self.appleParticles:emit(10)
        elseif object:hasTag('egg') then
            self.dustParticles:setPosition(x, y)
            self.dustParticles:emit(4)
        elseif object:hasTag('pet') then
            self.pets = self.pets - 1
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

    self:help()
end

function Game:update(dt)
    if self.selection then
        self.selection:drag(mousePosition:unpack())
    end
    self.appleParticles:update(dt)
    self.dustParticles:update(dt)
    self.container:update(dt)
    self.moneyOffsetTimer:update(dt)
    self.overlayTimer:update(dt)
    self.stats.time = self.stats.time + 1 / 60

    if self.nextPetTimer > 1 then
        self.nextPetTimer = self.nextPetTimer - 1
    else
        local x = math.random(32, Constants.GAME_WIDTH - 32)
        local y = math.random(32, Constants.GAME_HEIGHT - 32)
        Egg(self.container, x, y)
        self.dustParticles:setPosition(x, y)
        self.dustParticles:emit(2)
        self.pets = self.pets + 1
        self.stats.totalPets = self.stats.totalPets + 1

        if self.nextPetTimerMax < NEXT_PET_TIME_MAX then
            self.nextPetTimerMax = self.nextPetTimerMax + 60
        else
            self.nextPetTimerMax = NEXT_PET_TIME_MAX
        end
        self.nextPetTimer = self.nextPetTimerMax
    end
end

function Game:onLoseLife()
    sounds.DIE:play()
    if self.lives > 1 then
        self.lives = self.lives - 1
    else
        self.lives = 0
        self.overlayPos = 0
        self.overlayTimer:tween(120, self, {overlayPos = 1}, 'in-bounce', function()
            local Results = require 'src.states.Results'
            Gamestate.switch(Results, self.stats)
        end)
    end
end

function Game:onPayout()
    self.money = self.money + 1
    self.stats.totalMoney = self.stats.totalMoney + 1
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
        local x, y = crate:getPosition():unpack()
        x = x + math.random() - 0.5
        y = y - 12
        local apple = Apple(self.container, x, y)
        apple:select()
        self.selection = apple
        self.dustParticles:setPosition(x, y)
        self.dustParticles:emit(2)
        sounds.POP:play()
    end
end

function Game:help()
    local Instructions = require 'src.states.Instructions'
    Gamestate.push(Instructions)
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
        sounds.THUD_1:play()
    end
end

function Game:outlinedText(text, x, y)
    love.graphics.setColor(0, 0, 0)
    for i = -1, 1, 2 do
        love.graphics.print(text, x + i, y)
    end
    for j = -1, 1, 2 do
        love.graphics.print(text, x, y + j)
    end
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(text, x, y)
end

function Game:draw()
    self.container:draw()

    love.graphics.draw(self.dustParticles)
    love.graphics.draw(self.appleParticles)

    local x = 16
    love.graphics.draw(sprites.HEART, x, 3)
    if self.lives <= 1 then
        self:outlinedText(self.lives, x + 15, 2 + math.sin(self.stats.time * 30))
        love.graphics.setColor(215, 83, 21)
        love.graphics.print(self.lives, x + 15, 2 + math.sin(self.stats.time * 30))
        love.graphics.setColor(255, 255, 255)
    else
        self:outlinedText(self.lives, x + 15, 2)
    end

    x = x + 32
    love.graphics.draw(sprites.COIN, x, 3 - self.moneyOffset)
    self:outlinedText(self.money, x + 15, 2 - self.moneyOffset)

    if self.overlayPos > 0 then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('fill', 0, Constants.GAME_HEIGHT * (1 - self.overlayPos),
            Constants.GAME_WIDTH, Constants.GAME_HEIGHT)
        love.graphics.setColor(255, 255, 255)
    end
end

return Game
