local MathUtils = require "src.utils.math"
local TooltipButton = require "src.ui.tooltipButton"
local BuildType = require "src.gameplay.buildType"

local Tooltip = {}
Tooltip.__index = Tooltip

function Tooltip.new(map, width, height)
  local self = setmetatable({}, Tooltip)
  self.width = width
  self.height = height
  self.map = map
  self.x = -math.huge
  self.y = -math.huge
  self.isOpen = false

  self.canRepair = false
  self.canBuild = false
  self.canClear = false

  Events:subscribe("tooltip/open", function(island)
    if self.map:isAttached(island) then
      self:open(island)
    end
  end)

  Events:subscribe("tooltip/close", function()
    self.isOpen = false

    self.canRepair = false
    self.canBuild = false
    self.canClear = false
  end)

  self.buildButton = TooltipButton.new(
    80, 40, "build", function()
    Events:publish("buildPanel/show", self.island, self.island.build.buildType)
  end
  )

  self.repairButton = TooltipButton.new(
    80, 40, "repair", function()
    Events:publish("buildPanel/repair", self.island)
  end
  )

  self.clearButton = TooltipButton.new(
    80, 40, "clear", function()
    Events:publish("buildPanel/clear", self.island)
  end
  )

  return self
end

function Tooltip:updatePosition()
  local ix, iy = Screen:toScreen(self.island.x, self.island.y)

  self.x = ix - self.width / 2
  self.y = iy - 70

  self.repairButton:update(self.x, self.y)

  if self.canBuild then
    self.buildButton:update(self.x, self.y)
  end

  self.clearButton:update(self.x + 100, self.y)
end

function Tooltip:update()
  if self.island.health < 100 then
    self.canRepair = true
  end

  if self.isOpen then
    self:updatePosition()
    self.island.hovered = true
  end
end

function Tooltip:handleClick(x, y)
  if self.canRepair then
    self.repairButton:click(x, y)
  end

  if self.canBuild then
    self.buildButton:click(x, y)
  end

  self.clearButton:click(x, y)
end

function Tooltip:inBounds(x, y)
  return MathUtils.rectBounds(x, y, self.x, self.y, self.width, self.height)
end

function Tooltip:open(island)
  self.isOpen = true
  self.island = island

  if not self.island.build:hasHealth() then
    self.canBuild = true
  end

  if self.island.build.buildType ~= BuildType.None then
    self.canClear = true
  end
end

function Tooltip:draw()
  love.graphics.push("all")
  if self.isOpen then

    if self.canRepair then
      self.repairButton:draw()
    end

    if self.canBuild then
      self.buildButton:draw()
    end

    if not self.canBuild and not self.canRepair then
      love.graphics.setColor(1, 1, 1, 0.3)
      self.repairButton:draw()
      love.graphics.setColor(1, 1, 1, 1)
    end

    if not self.canClear then
      love.graphics.setColor(1, 1, 1, 0.3)
    end
    self.clearButton:draw()
  end
  love.graphics.pop()
end

return Tooltip
