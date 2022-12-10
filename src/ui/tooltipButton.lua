local Patchy = require "lib.patchy"

local MathUtils = require "src.utils.math"
local Font = require "src.utils.font"

local TooltipButton = {}
TooltipButton.__index = TooltipButton

TooltipButton.font = Font.upheaval(24)

function TooltipButton.new(w, h, text, onClick)
  local self = setmetatable({}, TooltipButton)
  self.w = w
  self.h = h
  self.text = text
  self.onClick = onClick
  self.sprite = Patchy.load("assets/ui/panel.9.png")
  return self
end

function TooltipButton:update(x, y)
  self.x = x
  self.y = y
end

function TooltipButton:click(x, y)
  print(x, y, self.x, self.y, self.w, self.h)
  if MathUtils.rectBounds(x, y, self.x, self.y, self.w, self.h) then
    self.onClick()
  end
end

function TooltipButton:draw()
  love.graphics.push("all")
  self.sprite:draw(self.x, self.y, self.w, self.h)
  love.graphics.print(
    self.text,
    TooltipButton.font,
    self.x + self.w / 2,
    self.y + self.h / 2,
    0, 1, 1,
    TooltipButton.font:getWidth(self.text) / 2,
    TooltipButton.font:getHeight() / 2
  )
  love.graphics.pop()
end

return TooltipButton
