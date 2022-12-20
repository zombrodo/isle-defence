local Plan = require "lib.plan"
local Container = Plan.Container

local Patchy = require "lib.patchy"

local Font = require "src.utils.font"
local MathUtils = require "src.utils.math"

local Button = Container:extend()

Button.font = Font.upheaval(24)
Button.patch = Patchy.load("assets/ui/panel.9.png")

function Button:new(rules, text, onClick)
  local button = Button.super.new(self, rules)
  button.text = text
  button.onClick = onClick
  return button
end

function Button:update(dt)
end

function Button:draw()
  love.graphics.push("all")
  Button.patch:draw(self.x, self.y, self.w, self.h)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(
    self.text,
    Button.font,
    self.x + self.w / 2,
    self.y + self.h / 2,
    0, 1, 1,
    Button.font:getWidth(self.text) / 2,
    Button.font:getHeight() / 2
  )
  love.graphics.pop()
end

function Button:mousepressed(x, y)
  if MathUtils.rectBounds(x, y, self.x, self.y, self.w, self.h) then
    self.onClick()
  end
end

return Button
