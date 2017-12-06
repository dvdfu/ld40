local Animation = require 'src.Animation'
local Constants = require 'src.Constants'
local Gamestate = require 'modules.hump.gamestate'
local Sprites = require 'src.Sprites'

local Instructions = {}

local quirks = {
    amanita = "Likes friends",
    chin = "Greedy eater",
    dasher = "Likes being pet, leaves a mess",
    dragon = "Breathes fire",
    ferro = "Hurts others",
    lumpy = "Drops apples, fears tombstones",
    mollusk = "Hard to move",
}

function Instructions:enter(previous)
    self.previous = previous
    self.petAnims = {
        amanita = Animation(Sprites.pet.amanita.IDLE, 2, 10),
        chin = Animation(Sprites.pet.chin.IDLE, 2, 10),
        dasher = Animation(Sprites.pet.dasher.IDLE, 2, 10),
        dragon = Animation(Sprites.pet.dragon.IDLE, 2, 10),
        ferro = Animation(Sprites.pet.ferro.IDLE, 2, 10),
        lumpy = Animation(Sprites.pet.lumpy.IDLE, 2, 10),
        mollusk = Animation(Sprites.pet.mollusk.IDLE, 2, 10),
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
