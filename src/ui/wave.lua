local Plan = require "lib.plan"
local Container = Plan.Container

local Fonts = require "src.utils.font"

local Wave = Container:extend()

Wave.font = Fonts.upheaval(32)
Wave.fontSmaller = Fonts.upheaval(24)
Wave.icon = love.graphics.newImage("assets/ships/enemy.png")

function Wave:new(rules)
  local wave = Wave.super.new(self, rules)
  wave.currentWave = 1
  wave.enemies = 4
  wave.tick = 45
  wave.timer = 0
  return wave
end

function Wave:update(dt)
  if math.floor(self.timer) < math.floor(self.timer + dt) then
    Events:publish("wave/second", math.floor(self.timer + dt))
  end

  self.timer = self.timer + dt

  if self.timer >= self.tick + 0.5 then
    Events:publish("wave/next", self.enemies)
    self.timer = 0
    self.currentWave = self.currentWave + 1
    self.enemies = math.floor(self.enemies * 1.5)
  end
end

function Wave:draw()
  love.graphics.push("all")
  love.graphics.print(string.format("Next Wave (wave %d) in %.0f", self.currentWave, self.tick - self.timer), Wave.font, self.x, self.y, 0, 1, 1, 0)
  love.graphics.draw(Wave.icon, self.x, self.y + Wave.font:getHeight(), 0, 2, 2)
  love.graphics.print("x " .. self.enemies, Wave.fontSmaller, self.x + Wave.icon:getWidth() * 2, self.y + Wave.font:getHeight())
  love.graphics.pop()
end

return Wave

