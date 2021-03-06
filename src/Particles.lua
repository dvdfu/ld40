local Sprites = require 'src.Sprites'

local function getQuads(n, w, h)
    local quads = {}
    for i = 1, n do
        quads[i] = love.graphics.newQuad((i - 1) * w, 0, w, h, w * n, h)
    end
    return quads
end

return {
    newApple = function()
        local ps = love.graphics.newParticleSystem(Sprites.particle.APPLE)
        ps:setAreaSpread('uniform', 8, 8)
        ps:setOffset(3, 3)
        ps:setParticleLifetime(10, 20)
        ps:setQuads(getQuads(4, 6, 6))
        ps:setSpeed(0.2, 0.8)
        ps:setSpread(math.pi)
        return ps
    end,
    newDust = function()
        local ps = love.graphics.newParticleSystem(Sprites.particle.DUST)
        ps:setAreaSpread('uniform', 4, 4)
        ps:setOffset(8, 8)
        ps:setParticleLifetime(10)
        ps:setQuads(getQuads(6, 16, 16))
        ps:setSpeed(0, 1)
        ps:setSpread(math.pi)
        return ps
    end,
    newExplosion = function()
        local ps = love.graphics.newParticleSystem(Sprites.particle.EXPLOSION)
        ps:setOffset(24, 44)
        ps:setParticleLifetime(30)
        ps:setQuads(getQuads(5, 48, 48))
        return ps
    end,
    newTears = function()
        local ps = love.graphics.newParticleSystem(Sprites.particle.TEARS)
        ps:setAreaSpread('uniform', 8, 0)
        ps:setDirection(-math.pi / 2)
        ps:setLinearAcceleration(0, 0.1)
        ps:setOffset(2, 2)
        ps:setParticleLifetime(10, 20)
        ps:setQuads(getQuads(2, 4, 4))
        ps:setSpeed(1, 2)
        ps:setSpread(math.pi / 4)
        return ps
    end,
}
