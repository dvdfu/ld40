local Class = require 'modules.hump.class'

local Container = Class.new()

local function doNothing() end

function Container:init(onDelete)
    self.objects = {}
    self.onDelete = onDelete or doNothing
end

function Container:update(dt)
    for i, object in pairs(self.objects) do
        if object:isDestroyed() then
            self.onDelete(object)
            object:onDelete()
            self.objects[i] = nil
        else
            object:update(dt)
        end
    end
end

function Container:add(object)
    table.insert(self.objects, object)
end

function Container:forEach(callback)
    for _, object in pairs(self.objects) do
        callback(object)
    end
end

function Container:draw()
    for _, object in pairs(self.objects) do
        object:draw()
    end
end

return Container
