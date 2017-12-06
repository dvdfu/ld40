local Gamestate  = require 'modules.hump.gamestate'
local Signal     = require 'modules.hump.signal'
local Timer      = require 'modules.hump.timer'
local Vector     = require 'modules.hump.vector'
local Constants  = require 'src.Constants'
local Container  = require 'src.Container'
local Particles  = require 'src.Particles'
local Sounds     = require 'src.Sounds'
local Sprites    = require 'src.Sprites'
local Apple      = require 'src.objects.Apple'
local AppleCrate = require 'src.objects.AppleCrate'
local Boundary   = require 'src.objects.Boundary'
local Egg        = require 'src.objects.Egg'
local Grass      = require 'src.objects.Grass'
local Tombstone  = require 'src.objects.Tombstone'

local Game = {}

local NEXT_PET_TIME = 180
local NEXT_PET_TIME_MAX = 540

local function help()
    local Instructions = require 'src.states.Instructions'
    Gamestate.push(Instructions)
end

function Game:init()
    local font = love.graphics.newFont('res/font/redalert.ttf', 13)
    love.graphics.setFont(font)

    Signal.register('payout', function(amount) self:onPayout(amount) end)
end

function Game:enter()
    self.gameOver = false
    self.selection = nil
    self.lives = 5
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
    self.nextPetDelay = NEXT_PET_TIME
    self.nextPetTimer = Timer()

    self.appleParticles = Particles.newApple()
    self.dustParticles = Particles.newDust()
    self.explosionParticles = Particles.newExplosion()

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
            self.explosionParticles:setPosition(x, y)
            self.explosionParticles:emit(1)
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

    help()
    self:spawnPet()
end

function Game:update(dt)
    if self.selection then
        self.selection:drag(mousePosition:unpack())
    end
    local mdt = dt
    if self.gameOver then
        mdt = dt / 4
    else
        self.stats.time = self.stats.time + dt
    end

    self.container:update(mdt)
    self.nextPetTimer:update(mdt)
    self.appleParticles:update(mdt)
    self.dustParticles:update(mdt)
    self.explosionParticles:update(mdt)

    self.moneyOffsetTimer:update(dt)
    self.overlayTimer:update(dt)
end

function Game:spawnPet()
    local x = math.random(32, Constants.GAME_WIDTH - 32)
    local y = math.random(32, Constants.GAME_HEIGHT - 32)
    Egg(self.container, x, y)
    self.dustParticles:setPosition(x, y)
    self.dustParticles:emit(2)
    self.pets = self.pets + 1
    self.stats.totalPets = self.stats.totalPets + 1

    self.nextPetDelay = self.nextPetDelay + 60
    if self.nextPetDelay > NEXT_PET_TIME_MAX then
        self.nextPetDelay = NEXT_PET_TIME_MAX
    end
    self.nextPetTimer:after(self.nextPetDelay, function() self:spawnPet() end)
end

function Game:onLoseLife()
    Sounds.ui.DIE:play()
    if self.lives > 1 then
        self.lives = self.lives - 1
    elseif not self.gameOver then
        self.gameOver = true
        self.lives = 0
        self.overlayTimer:after(180, function()
            self.overlayPos = 0
            self.overlayTimer:tween(120, self, {overlayPos = 1}, 'in-bounce', function()
                local Results = require 'src.states.Results'
                Gamestate.switch(Results, self.stats)
            end)
        end)
    end
end

function Game:onPayout(amount)
    if amount == 0 then return end
    self.money = self.money + amount
    self.stats.totalMoney = self.stats.totalMoney + amount
    self.moneyOffset = 4
    self.moneyOffsetTimer:clear()
    self.moneyOffsetTimer:tween(10, self, {moneyOffset = 0}, 'out-quad')
end

function Game:buyLife()
    if self.money < 50 then return end
    self.money = self.money - 50
    self.lives = self.lives + 1
end

function Game:buyApple(crate)
    if self.money < 5 then return end
    crate:onClick()
    self.money = self.money - 5
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
        Sounds.ui.THUD_1:play()
    end
end

local function outlinedText(text, x, y)
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
    love.graphics.draw(self.explosionParticles)

    local x = 16
    love.graphics.draw(Sprites.ui.HEART, x, 3)
    if self.lives <= 1 then
        outlinedText(self.lives, x + 15, 2 + math.sin(self.stats.time / 2))
        love.graphics.setColor(215, 83, 21)
        love.graphics.print(self.lives, x + 15, 2 + math.sin(self.stats.time / 2))
        love.graphics.setColor(255, 255, 255)
    else
        outlinedText(self.lives, x + 15, 2)
    end

    x = x + 32
    love.graphics.draw(Sprites.ui.COIN, x, 3 - self.moneyOffset)
    outlinedText(self.money, x + 15, 2 - self.moneyOffset)

    if self.overlayPos > 0 then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('fill', 0, Constants.GAME_HEIGHT * (1 - self.overlayPos),
            Constants.GAME_WIDTH, Constants.GAME_HEIGHT)
        love.graphics.setColor(255, 255, 255)
    end
end

return Game
