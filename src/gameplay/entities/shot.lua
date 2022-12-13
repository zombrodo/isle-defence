local Colour = require "src.utils.colour"

local Shot = {}
Shot.__index = Shot

function Shot.new(x, y, dx, dy)
  local self = setmetatable({}, Shot)
  self.x = x
  self.y = y
  self.dx = dx
  self.dy = dy
  self.speed = 200
  self.timer = 0
  self.maxLife = 1
  self.size = 3
  self.alive = true
  return self
end

function Shot:update(dt)
  self.x = self.x + self.dx * self.speed * dt
  self.y = self.y + self.dy * self.speed * dt

  self.timer = self.timer + dt
  if self.timer >= self.maxLife then
    self.alive = false
  end
end

function Shot:draw()
  love.graphics.push("all")
  love.graphics.setColor(Colour.fromHex("#222222"))
  love.graphics.circle("fill", self.x, self.y, self.size)
  love.graphics.pop()
end

return Shot
