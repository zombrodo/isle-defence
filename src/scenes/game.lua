local Windfield = require "lib.windfield"

local Colour = require "src.utils.colour"
local Map = require "src.gameplay.map"
local IslandSpawner = require "src.gameplay.spawners.island"
local Connector = require "src.gameplay.entities.connector"

local GameScene = {}
GameScene.__index = GameScene

function GameScene.new()
  local self = setmetatable({}, GameScene)
  return self
end

function GameScene:enter()
  self.physics = Windfield.newWorld(0, 0)

  self.islandSpawner = IslandSpawner.new(self.physics)
  self.map = Map.new(self.physics)

  self.currentConnector = nil
end

function GameScene:update(dt)
  self.physics:update(dt)
  self.map:update(dt)
end

function GameScene:draw()
  love.graphics.push("all")
  love.graphics.clear(Colour.Blue)
  self.map:draw()
  love.graphics.pop()
end

function GameScene:keypressed(key)
  if key == "p" then
    local new = self.islandSpawner:spawn()
    print(new)
    self.map:addIsland(new)
  end
end

function GameScene:attachConnector(island)
  if not self.currentConnector then
    self.currentConnector = Connector.new(self.physics)
  end

  island:attach(self.currentConnector)

  if self.currentConnector:isComplete() then
    self.currentConnector = nil
  end
end

function GameScene:mousepressed()
  for i, island in ipairs(self.map.islands) do
    if island.hovered then
      self:attachConnector(island)
    end
  end
end

return GameScene
