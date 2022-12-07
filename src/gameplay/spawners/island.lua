local Island = require "src.gameplay.island"

local IslandSpawner = {}
IslandSpawner.__index = IslandSpawner

IslandSpawner.mod = 175

function IslandSpawner.new(physics)
  local self = setmetatable({}, IslandSpawner)
  self.physics = physics
  return self
end

local direction = { "left", "right", "top", "bottom" }

function IslandSpawner:spawn()
  -- Direction is _where_ it comes from, not where its going.
  local dir = direction[love.math.random(1, 4)]

  local spawnX, spawnY, velX, velY

  if dir == "left" then
    spawnX = -20
    spawnY = love.math.random(20, GAME_HEIGHT - 20)
    velX = 20
    velY = 0
  end

  if dir == "right" then
    spawnX = GAME_WIDTH + 20
    spawnY = love.math.random(20, GAME_HEIGHT - 20)
    velX = -20
    velY = 0
  end

  if dir == "bottom" then
    spawnX = love.math.random(20, GAME_WIDTH - 20)
    spawnY = GAME_HEIGHT + 20
    velX = 0
    velY = -20
  end

  if dir == "top" then
    spawnX = love.math.random(20, GAME_WIDTH - 20)
    spawnY = -20
    velX = 0
    velY = 20
  end

  local island = Island.new(self.physics, spawnX, spawnY)
  island.body:applyLinearImpulse(
    velX * IslandSpawner.mod,
    velY * IslandSpawner.mod
  )

  return island
end

return IslandSpawner
