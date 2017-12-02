local Pet = require 'src.Pet'

local Game = {}

function Game:init()
end

function Game:enter()
    self.pets = {}
    self.selectedPet = nil
    table.insert(self.pets, Pet(50, 50))
end

function Game:update(dt)
    for _, pet in pairs(self.pets) do
        pet:update(dt)
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
    if not self.selectedPet then return end

    self.selectedPet:unselect()
    self.selectedPet = nil
end

function Game:mousemoved(x, y)
    if not self.selectedPet then return end

    self.selectedPet:move(x, y)
end

function Game:draw()
    for _, pet in pairs(self.pets) do
        pet:draw()
    end
end

return Game
