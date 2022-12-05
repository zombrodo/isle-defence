local SineGenerator = {}
SineGenerator.__index = SineGenerator

function SineGenerator.new(amplitude, magnitude, fuzz)
  local self = setmetatable({}, SineGenerator)
  self.amplitude = amplitude
  self.magnitude = magnitude
  self.fuzz = fuzz and love.math.random(1, 100) or 0
  return self
end

function SineGenerator:getValue()
  return self.amplitude * math.sin((love.timer.getTime() * math.pi / self.magnitude) + self.fuzz)
end

return SineGenerator
