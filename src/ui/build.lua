local Patchy = require "lib.patchy"
local Plan = require "lib.plan"
local Container = Plan.Container
local Rules = Plan.Rules
local RuleFactory = Plan.RuleFactory
local BuildType = require "src.gameplay.buildType"
local EvenlySpaced = require "src.ui.spaced"
local BuildOption = require "src.ui.buildOption"
local Build = require "src.gameplay.build"

local BuildPanel = Container:extend()

BuildPanel.background = Patchy.load("assets/ui/panel.9.png")

function BuildPanel:new(rules, stockpile)
  local panel = BuildPanel.super.new(self, rules)
  panel.stockpile = stockpile
  panel.visible = false
  panel.island = nil

  Events:subscribe("buildPanel/show", function(island, buildType)
    print("showing " .. buildType)
    panel:set(buildType)
    panel.island = island
    panel.visible = true
  end)

  Events:subscribe("buildPanel/build", function(buildType)
    panel.island.build = Build.new(buildType)
  end)

  Events:subscribe("buildPanel/hide", function()
    panel.visible = false
    panel.island = nil
  end)

  return panel
end

local function option(buildType)
  local x = BuildOption:new(Rules.new(), buildType)
  print("option", x)
  return x
end

local function buildOptions(buildType)
  if buildType == BuildType.None then
    return {
      option(BuildType.Farm),
      option(BuildType.Hemp),
      option(BuildType.House)
    }
  end

  if buildType == BuildType.Forest then
    return {
      option(BuildType.Woodcutter)
    }
  end

  if buildType == BuildType.Ore then
    return {
      option(BuildType.Mine)
    }
  end

  return nil
end

function BuildPanel:set(buildType)
  local opts = buildOptions(buildType)
  if opts then
    self:clearChildren()
    local options = EvenlySpaced.vertical(
      Rules.new()
      :addX(Plan.pixel(0))
      :addY(Plan.pixel(0))
      :addWidth(Plan.max())
      :addHeight(Plan.max()),
      opts,
      10
    )
    self:addChild(options)
    print("Added options", #opts, options)
  end

  BuildPanel.super.refresh(self)
end

function BuildPanel:draw()
  love.graphics.push("all")
  if self.visible then
    BuildPanel.background:draw(self.x, self.y, self.w, self.h)
    BuildPanel.super.draw(self)
  end
  love.graphics.pop()
end

return BuildPanel
