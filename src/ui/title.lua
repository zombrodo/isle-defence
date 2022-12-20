local Plan = require "lib.plan"
local Container = Plan.Container

local Font = require "src.utils.font"
local SineGenerator = require "src.utils.sine"

local Title = Container:extend()

Title.font = Font.upheaval(64)

function Title:new(rules, text)
  local title = Title.super.new(self, rules)
  title.text = text
  title.sine = SineGenerator.new(2, 1, true)
  return title
end

function Title:update(dt)
end

function Title:draw()
  love.graphics.push("all")
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.translate(0, self.sine:getValue())
  love.graphics.print(
    self.text,
    Title.font,
    self.x + self.w / 2,
    self.y + self.h / 2,
    0, 1, 1,
    Title.font:getWidth(self.text) / 2,
    Title.font:getHeight() / 2
  )
  love.graphics.pop()
end

return Title
