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
    if panel:canBuild(buildType) then
      panel.island.build = Build.new(buildType, panel.island)
      panel:spend(buildType)
      if buildType == BuildType.House then
        panel.stockpile:add(ResourceType.People, 10)
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

local function option(buildType)
  return BuildOption:new(Rules.new(), buildType)
end

local function buildOptions(buildType)
  if buildType == BuildType.None then
    return {
      option(BuildType.Farm),
      option(BuildType.Hemp),
      option(BuildType.House),
      option(BuildType.Tower)
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
