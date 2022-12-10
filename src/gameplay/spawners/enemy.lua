local Enemy = require "src.gameplay.entities.enemy"

local EnemySpawner = {}
EnemySpawner.__index = EnemySpawner

function EnemySpawner.new(physics)
  local self = setmetatable({}, EnemySpawner)
  self.physics = physics
  return self
end

function EnemySpawner.spawn(x, y)
  return Enemy.new(x, y)
end

return EnemySpawner
