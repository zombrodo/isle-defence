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
    Resource:new(Rules.new(), self.stockpile, ResourceType.Rope),
  }

  local panelRules = Rules.new()
      :addX(Plan.center())
      :addY(Plan.pixel(10))
      :addWidth(Plan.relative(0.6))
      :addHeight(Plan.pixel(60))

  local panel = Panel:new(panelRules)

  local stockpileRules = Rules.new()
      :addX(Plan.center())
      :addY(Plan.center())
      :addWidth(Plan.parent())
      :addHeight(Plan.pixel(60))

  local stockpile = EvenlySpaced.horizontal(stockpileRules, resources, 10)

  local buildRules = Rules.new()
      :addX(Plan.max(210))
      :addY(Plan.center())
      :addWidth(Plan.pixel(200))
      :addHeight(Plan.relative(0.75))

  local build = BuildPanel:new(buildRules)
  panel:addChild(stockpile)
  -- self.ui:addChild(panel)
  self.ui:addChild(build)
end

function GameScene:enter()
  self.physics = Windfield.newWorld(0, 0)
  self.islandSpawner = IslandSpawner.new(self.physics)
  self.map = Map.new(self.physics)

  self.enemySpawner = EnemySpawner.new(self.physics, self.map)
  self.enemies = {}

  -- UI
  self.ui = Plan.new()
  self.stockpile = Stockpile.new()
  self:__stockpileUI()
  self.tooltip = Tooltip.new(180, 40)

  self.currentConnector = nil
end

function GameScene:update(dt)
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
  if key == "p" then
    self.map:addIsland(self.islandSpawner:spawn())
  end

  if key == "e" then
    local mx, my = Screen:getMousePosition()
    table.insert(self.enemies, self.enemySpawner:spawn(mx, my))
  end
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
