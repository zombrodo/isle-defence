local Plan = require "lib.plan"
local Container = Plan.Container
local Rules = Plan.Rules

local Windfield = require "lib.windfield"

local Colour = require "src.utils.colour"
local Fonts = require "src.utils.font"
local Button = require "src.ui.button"

local Map = require "src.gameplay.map"

local TutorialScene = {}
TutorialScene.__index = TutorialScene

TutorialScene.promptFont = Fonts.upheaval(24)
TutorialScene.promptWidth = 300

function TutorialScene.new()
  local self = setmetatable({}, TutorialScene)
  self.currentStep = 1
  return self
end

function TutorialScene:enter()
  self.ui = Plan.new()

  local buttonRules = Rules.new()
      :addX(Plan.center())
      :addY(Plan.max(70))
      :addWidth(Plan.pixel(90))
      :addHeight(Plan.pixel(40))

  self.button = Button:new(buttonRules, "Next", function()
  end)

  self.ui:addChild(self.button)

  self.physics = Windfield.newWorld(0, 0)
  self.map = Map.new(self.physics)
end

function TutorialScene:update(dt)
  self.ui:update(dt)
  self.map:update(dt)
end

function TutorialScene:draw()
  love.graphics.push("all")
  love.graphics.clear(Colour.Blue)
  self.map:draw()
  love.graphics.pop()
end

function TutorialScene:drawPrompt()
  if self.currentStep == 1 then
    local x = self.map.root.x
    local y = self.map.root.y

    love.graphics.printf("Welcome to Isle Defence, a City Builder / Tower Defence game. To progress the tutorial, click 'Next'"
      , TutorialScene.promptFont, x, y, TutorialScene.promptWidth)
  end
end

function TutorialScene:drawUI()
  love.graphics.push("all")
  self.ui:draw()
  self:drawPrompt()
  love.graphics.pop()
end

function TutorialScene:mousepressed(x, y)
  self.ui:emit("mousepressed", x, y)
end

return TutorialScene
