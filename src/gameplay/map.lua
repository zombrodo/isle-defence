local BuildType = require "src.gameplay.buildType"
local Island = require "src.gameplay.island"
local Queue = require "src.utils.queue"
local Set = require "src.utils.set"

local Map = {}
Map.__index = Map

function Map.new(physics)
  local self = setmetatable({}, Map)
  self.physics = physics

  self.root = Island.new(physics, GAME_WIDTH / 2, GAME_HEIGHT / 2, BuildType.House)
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

function Map:update(dt, isTooltipOpen)
  for i, island in ipairs(self.islands) do
    island:update(dt, isTooltipOpen)
  end
  self:refreshDrawOrder()
end

local function filter(tbl, fn)
  local result = {}
  for i, elem in ipairs(tbl) do
    if fn(elem) then
      table.insert(result, elem)
    end
  end
  return result
end

function Map:updateEnemies(dt, enemies)
  local towers = filter(
    self.islands, function(island) return island.build:isTower() end
  )

  for i, tower in ipairs(towers) do
    tower.build:getTower():update(dt, enemies)
  end
end

local function isConnected(root, island)
  local queue = Queue.new()
  local visited = Set.new()

  for i, elem in ipairs(root.connections) do
    queue:offer(elem.child)
  end

  while not queue:isEmpty() do
    local e = queue:pop()
    if e == island then
      return true
    end

    visited:add(e)

    for i, conn in ipairs(e.connections) do
      if not visited:contains(conn.child) then
        queue:offer(conn.child)
      end
    end
  end

  return false
end

function Map:isAttached(island)
  if island == self.root then
    return true
  end

  return isConnected(self.root, island)
end

function Map:draw()
  love.graphics.push("all")
  for i, island in ipairs(self.islands) do
    island:draw()
  end
  love.graphics.pop()
end

return Map
