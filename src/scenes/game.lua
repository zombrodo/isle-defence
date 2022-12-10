local Windfield = require "lib.windfield"
local Plan = require "lib.plan"
local Rules = Plan.Rules

local Colour = require "src.utils.colour"
local Map = require "src.gameplay.map"
local IslandSpawner = require "src.gameplay.spawners.island"
local Connector = require "src.gameplay.entities.connector"
local ResourceType = require "src.gameplay.resourceType"

local Resource = require "src.ui.resource"
local EvenlySpaced = require "src.ui.spaced"
local Tooltip = require "src.ui.tooltip"
local Panel = require "src.ui.panel"

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

  self.ui = Plan.new()

  local resources = {
    Resource:new(Rules.new(), ResourceType.Wood),
    Resource:new(Rules.new(), ResourceType.Food),
    Resource:new(Rules.new(), ResourceType.Ore),
    Resource:new(Rules.new(), ResourceType.People),
    Resource:new(Rules.new(), ResourceType.Rope),
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

  panel:addChild(stockpile)
  self.ui:addChild(panel)

  self.tooltip = Tooltip.new(180, 40)

  self.currentConnector = nil
end

function GameScene:update(dt)
  self.physics:update(dt)
  self.map:update(dt)
  self.ui:update(dt)

  if self.currentConnector then
    self.currentConnector:update(dt)
  end

  if self.tooltip.isOpen then
    self.tooltip:update()
  end
end

function GameScene:draw()
  love.graphics.push("all")
  love.graphics.clear(Colour.Blue)
  self.map:draw()
  love.graphics.pop()
end

function GameScene:drawUI()
  love.graphics.push("all")
  self.ui:draw()
  self.tooltip:draw()
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

function GameScene:mousepressed(x, y, button)


  if self.tooltip.isOpen and self.tooltip:inBounds(x, y) then
    self.tooltip:handleClick(x, y)
  end

  if self.tooltip.isOpen then
    Events:publish("tooltip/close")
    return
  end

  print("eh?")

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
    print('detaching')
    self.currentConnector.parent:detach(self.currentConnector)
    self.currentConnector = nil
  end

end

return GameScene
