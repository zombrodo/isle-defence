local Colour = require "src.utils.colour"
local SineGenerator = require "src.utils.sine"
local MathUtils = require "src.utils.math"
local Shot = require "src.gameplay.entities.shot"

local Enemy = {}
Enemy.__index = Enemy

Enemy.sprite = love.graphics.newImage("assets/ships/enemy.png")

function Enemy.new(x, y, map)
  local self = setmetatable({}, Enemy)
  self.x = x
  self.y = y
  self.map = map

  self.w = Enemy.sprite:getWidth()
  self.h = Enemy.sprite:getHeight()

  self.health = 10
  self.alive = true

  self.bob = SineGenerator.new(1.2, 0.8, true)

  self.currentIsland = nil

  self.dx = 0
  self.dy = 0
  self.speed = 20

  self.timer = 0
  self.shootTimer = 1.4

  self.shots = {}

  return self
end

function Enemy:findClosestIsland()
  local distance = math.huge
  local nextIsland = nil

  for i, island in ipairs(self.map.islands) do
    if self.map:isAttached(island) and island.health > 0 then
      local dist = MathUtils.distance(self.x, self.y, island.x, island.y)
      if dist < distance then
        distance = dist
        nextIsland = island
      end
    end
  end

  if not nextIsland then
    return nil
  end

  self.currentIsland = nextIsland

  local angle = math.atan2(nextIsland.y - self.y, nextIsland.x - self.x)
  self.dx = math.cos(angle) * self.speed
  self.dy = math.sin(angle) * self.speed
end

function Enemy:check(shot)
  if self.currentIsland and self.currentIsland:collides(shot.x, shot.y) then
    self.currentIsland:damage(5)
    shot.alive = false

    if self.currentIsland.health == 0 then
      self.currentIsland = nil
    end
  end
end

function Enemy:update(dt)
  for i, shot in ipairs(self.shots) do
    self:check(shot)
  end

  if not self.currentIsland then
    self:findClosestIsland()
  end

  if self.currentIsland then
    if not self:inRange() then
      self.x = self.x + self.dx * dt
      self.y = self.y + self.dy * dt
    else
      if self.timer >= self.shootTimer then
        self:fire()
        self.timer = 0
      end
    end

    self.timer = self.timer + dt
  end

  for i = #self.shots, 1, -1 do
    self.shots[i]:update(dt)
    if not self.shots[i].alive then
      table.remove(self.shots, i)
    end
  end
end

function Enemy:inRange()
  return MathUtils.distance(
    self.x,
    self.y,
    self.currentIsland.x,
    self.currentIsland.y
  ) <= 60
end

function Enemy:fire()
  local angle = math.atan2(
    self.currentIsland.y - self.y,
    self.currentIsland.x - self.x
  )

  local nextShot = Shot.new(self.x, self.y, math.cos(angle), math.sin(angle))
  nextShot.size = 1

  table.insert(
    self.shots,
    nextShot
  )
end

function Enemy:collides(x, y)
  return MathUtils.rectBounds(x, y, self.x - self.w / 2, self.y - self.h / 2, self.w, self.h)
end

function Enemy:draw()
  love.graphics.push("all")
  love.graphics.translate(0, self.bob:getValue())
  love.graphics.draw(
    Enemy.sprite,
    self.x,
    self.y,
    0,
    1,
    1,
    Enemy.sprite:getWidth() / 2,
    Enemy.sprite:getHeight() / 2
  )

  for i, shot in ipairs(self.shots) do
    shot:draw()
  end

  love.graphics.setColor(Colour.withAlpha(Colour.fromHex("#222222"), 0.2))
  love.graphics.ellipse("fill", self.x, self.y + 30, 6, 3)
  love.graphics.pop()
end

return Enemy
