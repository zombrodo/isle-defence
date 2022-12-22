local Plan = require "lib.plan"
local Container = Plan.Container

local Timer = Container:extend()

function Timer:new(rules)
  local timer = Timer.super.new(self, rules)
  timer.time = 0
  timer.currentSegment = 0
  return timer
end

function Timer:update(dt)
  self.currentSegment = self.currentSegment + dt

  if self.currentSegment >= 15 then
    self.currentSegment = 0
  end
end

local function stencil(x, y, w, h)
  love.graphics.circle("fill", x, y + 10, 10)
  love.graphics.rectangle("fill", x + 10, y, w - 10, h)
  love.graphics.circle("fill", x + w - 10, y + h / 2, 10)
end

function Timer:draw()
  love.graphics.push("all")
  -- TODO: bleurgh
  love.graphics.stencil(function()
    stencil(self.x, self.y, self.w, self.h)
  end)
  Timer.super.draw(self)
  love.graphics.setColor(1, 0, 0, 1)
  love.graphics.rectangle(
    "fill",
    self.x,
    self.y,
    self.w,
    self.h
  )
  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.rectangle(
    "fill",
    self.x,
    self.y,
    self.w * (self.currentSegment / 15),
    self.h
  )
  love.graphics.pop()
end

return Timer
