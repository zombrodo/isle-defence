local Plan = require "lib.plan"
local Container = Plan.Container
local Rules = Plan.Rules

local Windfield = require "lib.windfield"

local Font = require "src.utils.font"
local SineGenerator = require "src.utils.sine"
local Colour = require "src.utils.colour"

local Button = require "src.ui.button"
local Title = require "src.ui.title"
local EvenlySpaced = require "src.ui.spaced"

local Map = require "src.gameplay.map"

local GameScene = require "src.scenes.game"

local MenuScene = {}
MenuScene.__index = MenuScene

MenuScene.titleFont = Font.upheaval(72)

function MenuScene.new()
  local self = setmetatable({}, MenuScene)
  self.sine = SineGenerator.new(2, 1, true)
  return self
end

function MenuScene:enter()
  self.ui = Plan.new()

  local buttons = {
    Button:new(Rules.new(), "Play", function() SceneManager:enter(GameScene.new()) end),
    Button:new(Rules.new(), "Tutorial", function() end),
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
    :addWidth(Plan.relative(0.3))
    :addHeight(Plan.relative(0.5))

  local container = Container:new(containerRules)

  container:addChild(buttonContainer)
  container:addChild(title)

  self.ui:addChild(container)

  self.physics = Windfield.newWorld(0, 0)
  self.map = Map.new(self.physics)
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
