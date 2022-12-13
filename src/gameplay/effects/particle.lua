local Colour = require "src.utils.colour"

local Particle = {}

Particle.particle = love.graphics.newImage("assets/other/particle.png")

function Particle.fire(colour)
  local ps = Particle.smoke(colour)
  ps:setSizes(1, 0.4, 0.2)
  ps:setEmissionRate(200)
  return ps
end

function Particle.smoke(colour)
  local ps = love.graphics.newParticleSystem(Particle.particle)
  ps:setParticleLifetime(1, 2)
  ps:setEmissionRate(10)
  ps:setSizeVariation(1)
  ps:setLinearAcceleration(0, -10, 0, -10)
  ps:setRadialAcceleration(-math.pi, math.pi)
  ps:setSpin(-math.pi, math.pi)
  ps:setSpinVariation(1)
  ps:setEmissionArea("uniform", 12, 2)
  ps:setColors(colour[1], colour[2], colour[3], 1)
  return ps
end

local Particles = {}
Particles.__index = Particles

function Particles.fire()
  local self = setmetatable({}, Particles)
  self.systems = {
    Particle.fire(Colour.fromHex("#cf573c")),
    Particle.fire(Colour.fromHex("#a53030")),
    Particle.fire(Colour.fromHex("#be772b")),
    Particle.fire(Colour.fromHex("#de9e41")),
  }
  return self
end

function Particles.smoke()
  local self = setmetatable({}, Particles)
  self.systems = {
    Particle.smoke(Colour.fromHex("#202e37")),
    Particle.smoke(Colour.fromHex("#394a50")),
    Particle.smoke(Colour.fromHex("#819796")),
    Particle.smoke(Colour.fromHex("#c7cfcc")),
  }
  return self
end

function Particles:update(dt)
  for i, ps in ipairs(self.systems) do
    ps:update(dt)
  end
end

function Particles:draw(x, y)
  love.graphics.push("all")
  for i, ps in ipairs(self.systems) do
    love.graphics.draw(ps, x, y)
  end
  love.graphics.pop()
end

return Particles
