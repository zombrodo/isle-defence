local Plan = require "lib.plan"
local Container = Plan.Container
local Rules = Plan.Rules

local Windfield = require "lib.windfield"

local Font = require "src.utils.font"
local Math = require "src.utils.math"
local SineGenerator = require "src.utils.sine"
local Colour = require "src.utils.colour"

local Button = require "src.ui.button"
local Title = require "src.ui.title"
local EvenlySpaced = require "src.ui.spaced"

local Map = require "src.gameplay.map"
local Island = require "src.gameplay.island"
local BuildType = require "src.gameplay.buildType"
local Connector = require "src.gameplay.entities.connector"

local GameScene = require "src.scenes.game"


local MenuScene = {}
MenuScene.__index = MenuScene

MenuScene.titleFont = Font.upheaval(72)

function MenuScene.new()
  local self = setmetatable({}, MenuScene)
  self.sine = SineGenerator.new(2, 1, true)
  return self
end

local function toggle(state)
  if state then
    return "ON"
  end

  return "OFF"
end

function MenuScene:enter()
  self.ui = Plan.new()

  self.musicState = Button:new(Rules.new(), "Music: " .. toggle(Settings.get("BG_MUSIC")), function()
    local curr = Settings.get("BG_MUSIC")
    Settings.set("BG_MUSIC", not curr)
    self.musicState.text = "Music: " .. toggle(not curr)

  end)

  self.soundState = Button:new(Rules.new(), "Sounds: " .. toggle(Settings.get("GAME_SOUNDS")), function()
    local curr = Settings.get("GAME_SOUNDS")
    Settings.set("GAME_SOUNDS", not curr)
    self.soundState.text = "Sounds: " .. toggle(not curr)
  end)

  local buttons = {
    Button:new(Rules.new(), "Play", function() SceneManager:enter(GameScene.new()) end),
    self.musicState,
    self.soundState,
    Button:new(Rules.new(), "Quit", function() love.event.quit() end),
  }

  local buttonRules = Rules.new()
      :addX(Plan.center())
      :addY(Plan.max(60))
      :addWidth(Plan.max())
      :addHeight(Plan.pixel(60))

  local buttonContainer = EvenlySpaced.horizontal(
    buttonRules,
    buttons,
    10
  )

  local titleRules = Rules.new()
      :addX(Plan.center())
      :addY(Plan.pixel(0))
      :addWidth(Plan.max())
      :addHeight(Plan.relative(0.1))

  local title = Title:new(titleRules, "Isle Defence")

  local containerRules = Rules.new()
      :addX(Plan.center())
      :addY(Plan.center())
      :addWidth(Plan.relative(0.5))
      :addHeight(Plan.relative(0.5))

  local container = Container:new(containerRules)

  container:addChild(buttonContainer)
  container:addChild(title)

  self.ui:addChild(container)

  self.physics = Windfield.newWorld(0, 0)
  self.map = Map.new(self.physics)

  self:generateMap()
end

function MenuScene:generateMap()
  local xSpread = 70
  local minY = (GAME_HEIGHT / 2) - 40
  local maxY = (GAME_HEIGHT / 2) + 40

  for i = 1, 3 do
    local minX = (GAME_WIDTH / 2) - xSpread
    local maxX = (GAME_WIDTH / 2) + xSpread
    for j = 1, love.math.random(3, 6) do
      local island = Island.new(
        self.physics,
        love.math.random(minX, maxX),
        love.math.random(minY, maxY),
        BuildType.fullRandom()
      )

      island.shouldRemove = false

      self.map:addIsland(island)

      if i == 1 then
        local connector = Connector.new(self.physics)
        self.map.root:attach(connector)
        island:attach(connector)
      else
        local dist = math.huge
        local parent = self.map.root

        for k, isle in ipairs(self.map.islands) do
          if self.map:isAttached(isle) and Math.distance(isle.x, isle.y, island.x, island.y) < dist then
            dist = Math.distance(isle.x, isle.y, island.x, island.y)
            parent = isle
          end
        end

        local connector = Connector.new(self.physics)
        parent:attach(connector)
        island:attach(connector)
      end
    end
    xSpread = xSpread + 70
  end



end

function MenuScene:update(dt)
  self.physics:update(dt)
  self.map:update(dt, false)
end

function MenuScene:draw()
  love.graphics.push("all")
  love.graphics.clear(Colour.Blue)
  self.map:draw()
  love.graphics.pop()
end

function MenuScene:drawUI()
  love.graphics.push("all")
  self.ui:draw()
  love.graphics.pop()
end

function MenuScene:mousepressed(x, y)
  self.ui:emit("mousepressed", x, y)
end

return MenuScene
