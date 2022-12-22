local BuildType = require "src.gameplay.buildType"
local Island = require "src.gameplay.island"
local Math = require "src.utils.math"
local Queue = require "src.utils.queue"
local Set = require "src.utils.set"

local Map = {}
Map.__index = Map

function Map.new(physics)
  local self = setmetatable({}, Map)
  self.physics = physics

  self.root = Island.new(physics, GAME_WIDTH / 2, GAME_HEIGHT / 2, BuildType.House)
  self.root.static = true
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

  for i = #self.islands, 1, -1 do
    local island = self.islands[i]
    island:update(dt, isTooltipOpen)
    if island.shouldRemove then
      print("removing")
      table.remove(self.islands, i)
    end
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
    island:draw(self.hoveredIsland == island)
  end
  love.graphics.pop()
end

function Map:mousemoved()
  self.hoveredIsland = nil
  for i = #self.islands, 1, -1 do
    if Math.circularBounds(
      self.islands[i].x, self.islands[i].y, 16, Screen:getMousePosition()
    ) then
      self.hoveredIsland = self.islands[i]
      return
    end
  end
end

function Map:isHovered(island)
  return self.hoveredIsland == island
end

return Map
