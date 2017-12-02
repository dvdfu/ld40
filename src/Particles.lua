local Particles = {}

local sprites = {
    APPLE = love.graphics.newImage('res/img/particles/apple.png'),
    DUST = love.graphics.newImage('res/img/particles/dust.png'),
}

local function getQuads(n, w, h)
    local quads = {}
    for i = 1, n do
        quads[i] = love.graphics.newQuad((i - 1) * w, 0, w, h, w * n, h)
    end
    return quads
end

function Particles.newApple()
    local ps = love.graphics.newParticleSystem(sprites.APPLE)
    ps:setAreaSpread('ellipse', 8, 8)
    ps:setOffset(3, 3)
    ps:setParticleLifetime(20)
    ps:setQuads(getQuads(4, 6, 6))
    ps:setSpeed(0.2, 0.8)
    ps:setSpread(math.pi)
    return ps
end

function Particles.newDust()
    local ps = love.graphics.newParticleSystem(sprites.DUST)
    ps:setAreaSpread('ellipse', 4, 4)
    ps:setOffset(8, 8)
    ps:setParticleLifetime(10)
    ps:setQuads(getQuads(6, 16, 16))
    ps:setSpeed(0, 1)
    ps:setSpread(math.pi)
    return ps
end

return Particles