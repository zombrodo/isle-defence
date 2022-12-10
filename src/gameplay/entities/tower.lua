local MathUtils = require "src.utils.math"
local Shot = require "src.gameplay.entities.shot"

local Tower = {}
Tower.__index = Tower

function Tower.new(island)
  local self = setmetatable({}, Tower)
  self.range = 120
  self.island = island
  self.x = island.x
  self.y = island.y
  self.currentEnemy = nil

  self.shootTimer = 0
  self.speed = 0.7

  self.shots = {}

  return self
end

function Tower:find(enemies)
  local r = math.huge
  local e = nil

  for i, enemy in ipairs(enemies) do
    local dist = MathUtils.distance(self.x, self.y, enemy.x, enemy.y)
    print(dist)
    if dist < r then
      r = dist
      e = enemy
    end
  end

  if e then
    self.currentEnemy = e
  end
end

function Tower:fire()
  local angle = math.atan2(
    self.currentEnemy.y - self.y, self.currentEnemy.x - self.x
  )

  table.insert(
    self.shots,
    Shot.new(self.x, self.y, math.cos(angle), math.sin(angle))
  )

end

function Tower:update(dt, enemies)
  self.x = self.island.x
  self.y = self.island.y

  -- If we don't have a current enemy, try to find one.
  if not self.currentEnemy and #enemies > 0 then
    self:find(enemies)
  end

  -- If still none, then break out
  if not self.currentEnemy then
    return
  end

  self.shootTimer = self.shootTimer + dt
  if self.shootTimer >= self.speed then
    self:fire()
    self.shootTimer = 0
  end

  for i = #self.shots, 1, -1 do
    self.shots[i]:update(dt)
    if not self.shots[i].alive then
      table.remove(self.shots, i)
    end
  end
end

function Tower:draw()
  love.graphics.push("all")
  for i, shot in ipairs(self.shots) do
    shot:draw()
  end
  love.graphics.pop()
end

return Tower
