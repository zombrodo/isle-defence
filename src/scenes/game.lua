local Windfield = require "lib.windfield"
local Plan = require "lib.plan"
local Rules = Plan.Rules

local Colour = require "src.utils.colour"
local Map = require "src.gameplay.map"
local IslandSpawner = require "src.gameplay.spawners.island"
local EnemySpawner = require "src.gameplay.spawners.enemy"
local Connector = require "src.gameplay.entities.connector"
local ResourceType = require "src.gameplay.resourceType"
local Stockpile = require "src.gameplay.stockpile"

local Resource = require "src.ui.resource"
local EvenlySpaced = require "src.ui.spaced"
local Tooltip = require "src.ui.tooltip"
local Panel = require "src.ui.panel"
local BuildPanel = require "src.ui.build"

-- local Timer = require "src.ui.timer"
local Wave = require "src.ui.wave"

local GameScene = {}
GameScene.__index = GameScene

function GameScene.new()
  local self = setmetatable({}, GameScene)
  return self
end

function GameScene:__stockpileUI()
  local resources = {
    Resource:new(Rules.new(), self.stockpile, ResourceType.Wood),
    Resource:new(Rules.new(), self.stockpile, ResourceType.Food),
    Resource:new(Rules.new(), self.stockpile, ResourceType.Ore),
    Resource:new(Rules.new(), self.stockpile, ResourceType.People),
    Resource:new(Rules.new(), self.stockpile, ResourceType.Villagers),
    Resource:new(Rules.new(), self.stockpile, ResourceType.Rope),
  }

  local stockpileRules = Rules.new()
      :addX(Plan.pixel(10))
      :addY(Plan.center())
      :addWidth(Plan.pixel(200))
      :addHeight(Plan.relative(0.5))

  local stockpile = EvenlySpaced.vertical(stockpileRules, resources, 10)

  local buildRules = Rules.new()
      :addX(Plan.max(210))
      :addY(Plan.center())
      :addWidth(Plan.pixel(200))
      :addHeight(Plan.relative(0.75))

  local timerRules = Rules.new()
      :addX(Plan.center())
      :addY(Plan.pixel(40))
      :addHeight(Plan.pixel(20))
      :addWidth(Plan.relative(0.6))

  self.timer = Wave:new(timerRules)

  local build = BuildPanel:new(buildRules, self.stockpile)
  self.ui:addChild(stockpile)
  self.ui:addChild(build)
  self.ui:addChild(self.timer)
end

function GameScene:enter()
  self.physics = Windfield.newWorld(0, 0)
  self.islandSpawner = IslandSpawner.new(self.physics)
  self.map = Map.new(self.physics)

  Events:subscribe("wave/second", function(t)
    if t % 2 == 0 then
      self.map:addIsland(self.islandSpawner:spawn())
    end
  end)

  self.enemySpawner = EnemySpawner.new(self.physics, self.map)
  self.enemies = {}

  Events:subscribe("wave/next", function(n)
    self:spawnWave(n)
  end)

  -- UI
  self.ui = Plan.new()
  self.stockpile = Stockpile.new()
  self:__stockpileUI()
  self.tooltip = Tooltip.new(self.map, 180, 40)

  self.lost = false

  self.currentConnector = nil
  Audio.load("connect", "assets/audio/rope-connect.mp3")
  Audio.load("enemy", "assets/audio/battle-horn.mp3")
  Audio.load("bg", "assets/audio/Angevin.mp3")
  Audio.play("bg")

  Events:subscribe("wave/next", function()
    Audio.play("enemy")
  end)

  self.timer = 0
  self.every = 5
end

function GameScene:exit()
  Audio.__cache["bg"]:stop()
end

function GameScene:spawnWave(n)
  print("spawning", n)
  for i = 1, n do
    table.insert(self.enemies, self.enemySpawner:spawn(
      GAME_WIDTH + love.math.random(10, 20),
      love.math.random(0, GAME_HEIGHT)
    ))
  end
end

function GameScene:update(dt)
  if self.lost then
    error("YOU'RE DEAD, JIM")
  end


  self.physics:update(dt)
  self.ui:update(dt)

  if self.currentConnector then
    self.currentConnector:update(dt)
  end

  if self.tooltip.isOpen then
    self.tooltip:update()
  end

  for i, enemy in ipairs(self.enemies) do
    enemy:update(dt)
  end

  self.map:updateEnemies(dt, self.enemies)

  for i = #self.enemies, 1, -1 do
    if not self.enemies[i].alive then
      table.remove(self.enemies, i)
    end
  end

  self.timer = self.timer + dt

  if self.timer >= self.every then
    self.stockpile:remove(
      ResourceType.Food,
      math.floor(self.stockpile:get(ResourceType.Villagers) / 2)
    )
    self.timer = 0
  end

  if self.stockpile:get(ResourceType.Food) <= 0 then
    self.lost = true
  end

  self.map:update(dt, self.tooltip.isOpen)
end

function GameScene:draw()
  love.graphics.push("all")
  love.graphics.clear(Colour.Blue)
  self.map:draw()

  for i, enemy in ipairs(self.enemies) do
    enemy:draw()
  end

  love.graphics.pop()
end

function GameScene:drawUI()
  love.graphics.push("all")
  self.ui:draw()
  self.tooltip:draw()
  love.graphics.pop()


  -- Render cost
  if self.currentConnector then
    self.currentConnector:drawCost(self.stockpile)
  end
end

function GameScene:keypressed(key)
end

function GameScene:attachConnector(island)
  if not self.currentConnector then
    self.currentConnector = Connector.new(self.physics)
  end

  if self.currentConnector:canConnect(self.stockpile) then
    island:attach(self.currentConnector)
  end

  if self.currentConnector:isComplete() then
    self.stockpile:remove(ResourceType.Rope, self.currentConnector:getCost())
    Audio.play("connect")
    self.currentConnector = nil
  end
end

function GameScene:mousepressed(x, y, button)
  self.ui:emit("mousepressed", x, y)

  if self.tooltip.isOpen and self.tooltip:inBounds(x, y) then
    self.tooltip:handleClick(x, y)
  end

  if self.tooltip.isOpen then
    Events:publish("tooltip/close")
    return
  end

  for i, island in ipairs(self.map.islands) do
    if island.hovered then
      if button == 1 then
        if (not self.currentConnector and self.map:isAttached(island))
            or self.currentConnector then
          self:attachConnector(island)
          return
        end
      end

      if button == 2 then
        if not self.tooltip.isOpen then
          Events:publish("tooltip/open", island)
          return
        end
      end
    end
  end

  if self.currentConnector then
    self.currentConnector.parent:detach(self.currentConnector)
    self.currentConnector = nil
  end

end

return GameScene
