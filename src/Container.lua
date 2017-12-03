local Class = require 'modules.hump.class'

local Container = Class.new()

local function doNothing() end

function Container:init(onDelete)
    self.objects = {}
    self.drawOrders = {}
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
    local d = object:getDrawOrder()
    if not self.drawOrders[d] then
        self.drawOrders[d] = {object}
    else
        table.insert(self.drawOrders[d], object)
    end
end

function Container:forEach(callback)
    for _, object in pairs(self.objects) do
        callback(object)
    end
end

function Container:draw()
    for d, objects in pairs(self.drawOrders) do
        for i, object in pairs(objects) do
            if object:isDestroyed() then
                objects[i] = nil
            else
                object:draw()
            end
        end
    end
end

return Container
