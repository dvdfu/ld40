local Timer = require 'modules.hump.timer'

local Squishable = {}

DEFAULT_SQUISH = 2
DEFAULT_TIME = 60

function Squishable:init()
    self._squish = 1
    self._squishTimer = Timer()
end

function Squishable:update(dt)
    self._squishTimer:update(dt)
end

function Squishable:squish(amount, time)
    amount = amount or DEFAULT_SQUISH
    time = time or DEFAULT_TIME
    self._squish = amount
    self._squishTimer:clear()
    self._squishTimer:tween(time, self, {_squish = 1}, 'out-elastic')
end

function Squishable:getSquish()
    return self._squish, 1 / self._squish
end

return Squishable
