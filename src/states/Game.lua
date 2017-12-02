local Pet = require 'src.Pet'

local Game = {}

function Game:init()
end

function Game:enter()
    self.pets = {}
    table.insert(self.pets, Pet(50, 50))
end

function Game:update(dt)
    for _, pet in pairs(self.pets) do
        pet:update(dt)
    end
end

function Game:mousepressed(x, y)
end

function Game:mousereleased(x, y)
end

function Game:mousemoved(x, y)
end

function Game:draw()
    for _, pet in pairs(self.pets) do
        pet:draw()
    end
end

return Game
