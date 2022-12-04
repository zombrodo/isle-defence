local SineGenerator = {}
SineGenerator.__index = SineGenerator

function SineGenerator.new(amplitude, magnitude)
  local self = setmetatable({}, SineGenerator)
  self.amplitude = amplitude
  self.magnitude = magnitude
  return self
end

function SineGenerator:getValue()
  return self.amplitude * math.sin(love.timer.getTime() * math.pi / self.magnitude)
end

return SineGenerator
