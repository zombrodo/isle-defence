local MathUtils = require "src.utils.math"
local TooltipButton = require "src.ui.tooltipButton"

local Tooltip = {}
Tooltip.__index = Tooltip

function Tooltip.new(width, height)
  local self = setmetatable({}, Tooltip)
  self.width = width
  self.height = height
  self.x = -math.huge
  self.y = -math.huge
  self.isOpen = false

  Events:subscribe("tooltip/open", function(island) self:open(island) end)
  Events:subscribe("tooltip/close", function() self.isOpen = false end)

  self.buildButton = TooltipButton.new(
    80, 40, "build", function() print("dang") end
  )

  self.clearButton = TooltipButton.new(
    80, 40, "clear", function() print("dong") end
  )

  return self
end

function Tooltip:updatePosition()
  local ix, iy = Screen:toScreen(self.island.x, self.island.y)

  self.x = ix - self.width / 2
  self.y = iy - 70

  self.buildButton:update(self.x, self.y)
  self.clearButton:update(self.x + 100, self.y)
end

function Tooltip:update()
  if self.isOpen then
    self:updatePosition()
    self.island.hovered = true
  end
end

function Tooltip:handleClick(x, y)
  self.buildButton:click(x, y)
  self.clearButton:click(x, y)
end

function Tooltip:inBounds(x, y)
  return MathUtils.rectBounds(x, y, self.x, self.y, self.width, self.height)
end

function Tooltip:open(island)
  self.isOpen = true
  self.island = island
end

function Tooltip:draw()
  love.graphics.push("all")
  if self.isOpen then
    self.buildButton:draw()
    self.clearButton:draw()
  end
  love.graphics.pop()
end

return Tooltip
