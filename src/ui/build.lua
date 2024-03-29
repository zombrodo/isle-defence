local Patchy = require "lib.patchy"
local Plan = require "lib.plan"
local Container = Plan.Container
local Rules = Plan.Rules
local RuleFactory = Plan.RuleFactory
local BuildType = require "src.gameplay.buildType"
local EvenlySpaced = require "src.ui.spaced"
local BuildOption = require "src.ui.buildOption"
local Build = require "src.gameplay.build"
local ResourceType = require "src.gameplay.resourceType"
local BuildButton = require "src.ui.buildButton"
local MathUtils = require "src.utils.math"

local BuildPanel = Container:extend()

BuildPanel.background = Patchy.load("assets/ui/panel.9.png")
BuildPanel.optionHeight = 70
BuildPanel.optionGap = 10

function BuildPanel:new(rules, stockpile)
  local panel = BuildPanel.super.new(self, rules)
  panel.stockpile = stockpile
  panel.visible = false
  panel.island = nil

  Events:subscribe("buildPanel/show", function(island, buildType)
    panel:set(buildType)
    panel.island = island
    panel.visible = true
  end)

  Events:subscribe("buildPanel/build", function(buildType)
    if panel:canBuild(buildType) then
      panel.island.build = Build.new(buildType, panel.island)
      panel:spend(buildType)
      if buildType == BuildType.House then
        panel.stockpile:add(ResourceType.People, 10)
        panel.stockpile:add(ResourceType.Villagers, 10)
      end
    end
  end)

  Events:subscribe("buildPanel/clear", function(island)
    if island.build.buildType == BuildType.Forest then
      panel.stockpile:add(ResourceType.Wood, 15)
    end

    if island.build.buildType == BuildType.Ore then
      panel.stockpile:add(ResourceType.Ore, 15)
    end

    island.build = Build.new(BuildType.None, island)
  end)

  Events:subscribe("buildPanel/repair", function(island)
    panel:spend(island.build.buildType, island.health / 100)
    island.health = 100
  end)

  Events:subscribe("buildPanel/hide", function()
    panel.visible = false
    panel:clearChildren()
    panel.island = nil
  end)

  return panel
end

function BuildPanel:canBuild(buildType, modifier)
  local cost = BuildType.cost(buildType)
  local mod = modifier or 1
  for resource, amount in pairs(cost) do
    if not self.stockpile:has(resource, math.floor(amount * mod)) then
      return false
    end
  end
  return true
end

function BuildPanel:spend(buildType, modifier)
  local cost = BuildType.cost(buildType)
  local mod = modifier or 1
  for resource, amount in pairs(cost) do
    self.stockpile:remove(resource, math.floor(amount * mod))
  end
end

function BuildPanel:option(buildType)
  local wrapper = BuildOption:new(Rules.new(), buildType)
  local rules = Rules.new()
      :addX(Plan.center())
      :addY(Plan.center())
      :addWidth(200)
      :addHeight(70)

  wrapper:addChild(BuildButton:new(rules, buildType, self.stockpile))
  return wrapper
end

function BuildPanel:buildOptions(buildType)
  if buildType == BuildType.None then
    return {
      self:option(BuildType.Farm),
      self:option(BuildType.Hemp),
      self:option(BuildType.House),
      self:option(BuildType.Tower)
    }
  end

  if buildType == BuildType.Forest then
    return {
      self:option(BuildType.Woodcutter)
    }
  end

  if buildType == BuildType.Ore then
    return {
      self:option(BuildType.Mine)
    }
  end

  return nil
end

function BuildPanel:set(buildType)
  local opts = self:buildOptions(buildType)
  if opts then
    self:clearChildren()
    local totalHeight = #opts * (BuildPanel.optionHeight + BuildPanel.optionGap)
    self.rules:addHeight(totalHeight)
    local options = EvenlySpaced.vertical(
      Rules.new()
      :addX(Plan.pixel(0))
      :addY(Plan.pixel(0))
      :addWidth(Plan.max())
      :addHeight(totalHeight),
      opts,
      10
    )
    self:addChild(options)
  end

  BuildPanel.super.refresh(self)
end

function BuildPanel:draw()
  love.graphics.push("all")
  if self.visible then
    BuildPanel.super.draw(self)
  end
  love.graphics.pop()
end

function BuildPanel:mousepressed(x, y)
  if not MathUtils.rectBounds(x, y, self.x, self.y, self.w, self.h) then
    self.visible = false
  end
end

return BuildPanel
