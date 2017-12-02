local Pet = require 'src.Pet'
local Vector = require 'modules.hump.vector'

local Game = {}

local cursor = love.graphics.newImage('assets/cursor.png')

function Game:init()
end

function Game:enter()
    self.pets = {}
    self.selectedPet = nil
    for i = 1, 10 do
        table.insert(self.pets, Pet(i * 10, i * 10))
    end

    self.mousePosition = Vector(0, 0)
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
    if self.selectedPet then
        self.selectedPet:unselect()
        self.selectedPet = nil
    end
end

function Game:mousemoved(x, y)
    self.mousePosition.x = x
    self.mousePosition.y = y
    if self.selectedPet then
        self.selectedPet:move(x, y)
    end
end

function Game:draw()
    for _, pet in pairs(self.pets) do
        pet:draw()
    end
    love.graphics.draw(cursor, self.mousePosition.x, self.mousePosition.y, 0, 1, 1, 4, 1)
end

return Game
