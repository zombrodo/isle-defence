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

function Map:update(dt)
  for i, island in ipairs(self.islands) do
    island:update(dt)
  end
  self:refreshDrawOrder()
end

local function dfs(root, island)
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
  print(island, self.root)
  if island == self.root then
    return true
  end

  return dfs(self.root, island)
end

function Map:draw()
  love.graphics.push("all")
  for i, island in ipairs(self.islands) do
    island:draw()
  end
  love.graphics.pop()
end

return Map
