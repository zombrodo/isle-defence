local Windfield = require "lib.windfield"
local Plan = require "lib.plan"
local Rules = Plan.Rules

local Font = require "src.utils.font"
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
local Button = require "src.ui.button"
local BuildPanel = require "src.ui.build"

-- local Timer = require "src.ui.timer"
local Wave = require "src.ui.wave"

local GameScene = {}
GameScene.__index = GameScene

GameScene.font = Font.upheaval(72)

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
      :addX(Plan.center())
      :addY(Plan.pixel(100))
      :addWidth(Plan.relative(0.5))
      :addHeight(Plan.pixel(60))

  self.inventory = EvenlySpaced.horizontal(stockpileRules, resources, 10)

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

  self.waveTimer = Wave:new(timerRules)

  local build = BuildPanel:new(buildRules, self.stockpile)
  self.ui:addChild(self.inventory)
  self.ui:addChild(build)
  self.ui:addChild(self.waveTimer)

  print(self.timer)
end

function GameScene:enter(previous)
  self.previousScene = previous
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
  self.paused = false

  self.currentConnector = nil
  Audio.load("connect", "assets/audio/rope-connect.mp3")
  Audio.load("enemy", "assets/audio/battle-horn.mp3")
  Audio.load("bg", "assets/audio/Angevin.mp3")

  if Settings.get("BG_MUSIC") then
    Audio.play("bg")
  end

  Events:subscribe("wave/next", function()
    if Settings.get("GAME_SOUNDS") then
      Audio.play("enemy")
    end
  end)

  self.timer = 0
  self.every = 5
end

function GameScene:spawnWave(n)
  for i = 1, n do
    table.insert(self.enemies, self.enemySpawner:spawn(
      GAME_WIDTH + love.math.random(10, 20),
      love.math.random(0, GAME_HEIGHT)
    ))
  end
end

function GameScene:gameOver()
  self.ui:removeChild(self.waveTimer)
  self.ui:removeChild(self.inventory)

  local buttonRules = Rules.new()
      :addX(Plan.center())
      :addY(Plan.max(80))
      :addWidth(Plan.pixel(90))
      :addHeight(Plan.pixel(40))

  local button = Button:new(buttonRules, "Menu", function()
    if Settings.get("BG_MUSIC") then
      Audio.__cache["bg"]:stop()
    end

    SceneManager:enter(self.previousScene)
  end)

  self.lost = true
  self.ui:addChild(button)
end

function GameScene:update(dt)
  if self.paused or self.lost then
    return
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

  if self.stockpile:get(ResourceType.Food) <= 0
      or self.map.root.health == 0 then
    self:gameOver()
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


  -- Render cost
  if self.currentConnector then
    self.currentConnector:drawCost(self.stockpile)
  end


  if self.paused then
    love.graphics.setColor(Colour.withAlpha(Colour.fromHex("#394a50"), 0.5))
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(Colour.fromHex("#202e37"))
    love.graphics.print(
      "Paused", GameScene.font, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 0, 1, 1,
      GameScene.font:getWidth("Paused") / 2, GameScene.font:getHeight() / 2
    )
  end

  if self.lost then
    love.graphics.setColor(Colour.fromHex("#202e37"))
    love.graphics.print(
      "Game Over", GameScene.font, love.graphics.getWidth() / 2, 60, 0, 1, 1,
      GameScene.font:getWidth("Game Over") / 2, GameScene.font:getHeight() / 2
    )

    local font = Font.upheaval(48)

    local content = "Your people ran out of food"
    if self.map.root.health == 0 then
      content = "Your town center has been destroyed"
    end

    love.graphics.print(
      content, font, love.graphics.getWidth() / 2, 100, 0, 1, 1,
      font:getWidth(content) / 2, font:getHeight() / 2
    )
  end

  love.graphics.pop()
end

function GameScene:keypressed(key)
  if key == "escape" and not self.lost then
    self.paused = not self.paused
  end
end

function GameScene:attachConnector(island)
  if not self.currentConnector then
    self.currentConnector = Connector.new(self.physics)
  end

  if self.currentConnector:canConnect(self.stockpile)
      and self.currentConnector.parent ~= island
  then
    island:attach(self.currentConnector)
  end

  if self.currentConnector:isComplete() then
    self.stockpile:remove(ResourceType.Rope, self.currentConnector:getCost())
    if Settings.get("GAME_SOUNDS") then
      Audio.play("connect")
    end
    self.currentConnector = nil
  end
end

function GameScene:mousepressed(x, y, button)
  if self.lost then
    return
  end

  self.ui:emit("mousepressed", x, y)

  if self.tooltip.isOpen and self.tooltip:inBounds(x, y) then
    self.tooltip:handleClick(x, y)
  end

  if self.tooltip.isOpen then
    Events:publish("tooltip/close")
    return
  end

  for i, island in ipairs(self.map.islands) do
    if self.map:isHovered(island) then
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

function GameScene:mousemoved()
  if self.lost then
    return
  end

  self.map:mousemoved()
end

return GameScene
