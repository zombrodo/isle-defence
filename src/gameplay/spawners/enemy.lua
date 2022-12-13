local Enemy = require "src.gameplay.entities.enemy"

local EnemySpawner = {}
EnemySpawner.__index = EnemySpawner

function EnemySpawner.new(physics, map)
  local self = setmetatable({}, EnemySpawner)
  self.physics = physics
  self.map = map
  return self
end

function EnemySpawner:spawn(x, y)
  return Enemy.new(x, y, self.map)
end

return EnemySpawner
