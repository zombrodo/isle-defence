local Island = require "src.gameplay.island"

local Map = {}
Map.__index = Map

function Map.new(physics)
  local self = setmetatable({}, Map)
  self.physics = physics

  self.root = Island.new(physics, GAME_WIDTH / 2, GAME_HEIGHT / 2)
  self.root.body:setType("static")

  self.islands = { self.root }
  return self
end

function Map:refreshDrawOrder()
  table.sort(self.islands, function(a, b)
    return a.y < b.y
  end)
end

function Map:addIsland(island)
  table.insert(self.islands, island)
end

function Map:update(dt)
  for i, island in ipairs(self.islands) do
    island:update(dt)
  end
  self:refreshDrawOrder()
end

function Map:draw()
  love.graphics.push("all")
  for i, island in ipairs(self.islands) do
    island:draw()
  end
  love.graphics.pop()
end

return Map
