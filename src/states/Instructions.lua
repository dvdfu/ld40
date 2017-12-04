local Animation = require 'src.Animation'
local Constants = require 'src.Constants'
local Gamestate = require 'modules.hump.gamestate'

local Instructions = {}

local sprites = {
    amanita = love.graphics.newImage('res/img/pet/amanita.png'),
    chin = love.graphics.newImage('res/img/pet/chin.png'),
    dasher = love.graphics.newImage('res/img/pet/dasher.png'),
    dragon = love.graphics.newImage('res/img/pet/dragon.png'),
    ferro = love.graphics.newImage('res/img/pet/ferro.png'),
    lumpy = love.graphics.newImage('res/img/pet/lumpy.png'),
    mollusk = love.graphics.newImage('res/img/pet/mollusk.png'),
}

local quirks = {
    amanita = "Likes having friends",
    chin = "Greedy eater",
    dasher = "Likes being pet, leaves a mess",
    dragon = "Starts fires",
    ferro = "Hurts others",
    lumpy = "Drops apples, fears death",
    mollusk = "Hard to move",
}

function Instructions:enter(previous)
    self.previous = previous
    self.petAnims = {
        amanita = Animation(sprites.amanita, 2, 10),
        chin = Animation(sprites.chin, 2, 10),
        dasher = Animation(sprites.dasher, 2, 10),
        dragon = Animation(sprites.dragon, 2, 10),
        ferro = Animation(sprites.ferro, 2, 10),
        lumpy = Animation(sprites.lumpy, 2, 10),
        mollusk = Animation(sprites.mollusk, 2, 10),
    }
end

function Instructions:update(dt)
    for _, anim in pairs(self.petAnims) do
        anim:update(dt)
    end
end

function Instructions:mousepressed(x, y)
    Gamestate.pop()
end

function Instructions:draw()
    self.previous:draw()
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.rectangle('fill', 0, 0, Constants.GAME_WIDTH, Constants.GAME_HEIGHT)
    love.graphics.setColor(255, 255, 255, 255)
    local i = 0
    for name, anim in pairs(self.petAnims) do
        anim:draw(64, 32 + i * 20)
        love.graphics.print(quirks[name], 96, 34 + i * 20)
        i = i + 1
    end
end

return Instructions
