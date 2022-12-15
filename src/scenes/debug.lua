local Plan = require "lib.plan"
local Rules = Plan.Rules

local BuildType = require "src.gameplay.buildType"
local BuildButton = require "src.ui.buildButton"

local DebugScene = {}
DebugScene.__index = DebugScene

function DebugScene.new()
  local self = setmetatable({}, DebugScene)
  self.ui = Plan.new()

  local buttonRules = Rules.new()
      :addX(Plan.center())
      :addY(Plan.center())
      :addWidth(200)
      :addHeight(70)

  local button = BuildButton:new(buttonRules, BuildType.Tower)

  self.ui:addChild(button)
  return self
end

function DebugScene:update(dt)
  self.ui:update(dt)
end

function DebugScene:draw()
  love.graphics.push("all")
  love.graphics.pop()
end

function DebugScene:drawUI()
  self.ui:draw()
end

return DebugScene
