local Windfield = require "lib.windfield"

local Colour = require "src.utils.colour"
local Map = require "src.gameplay.map"
local IslandSpawner = require "src.gameplay.spawners.island"
local Rope = require "src.gameplay.entities.rope"

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

  self.currentRope = nil
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

function GameScene:handleRope(island)
  if not self.currentRope then
    if island.connection then
      print("picking up")
      self.currentRope = island.connection
      island:detach()
    else
      print("new wire")
      self.currentRope = Rope.new(self.physics)
      island:attach(self.currentRope)
    end
    return
  end

  if self.currentRope:canSet(island) then
    print("finishing")
    island:attach(self.currentRope)
    self.currentRope = nil
  end
end

function GameScene:mousepressed(_, _, button)
  local x, y = Screen:getMousePosition()

  if self.currentRope and button == 2 then
    self.currentRope:clear()
    self.currentRope = nil
  end

  for i, island in ipairs(self.map.islands) do
    if island.hovered then
      self:handleRope(island)
    end
  end
end

return GameScene
