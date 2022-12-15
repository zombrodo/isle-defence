local Plan = require "lib.plan"
local Container = Plan.Container

local MathUtils = require "src.utils.math"

local BuildOption = Container:extend()

function BuildOption:new(rules, buildType)
  local option = BuildOption.super.new(self, rules)
  option.buildType = buildType
  return option
end

function BuildOption:draw()
  love.graphics.push("all")
  BuildOption.super.draw(self)
  -- love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
  love.graphics.pop()
end

function BuildOption:mousepressed(x, y)
  if MathUtils.rectBounds(x, y, self.x, self.y, self.w, self.h) then
    Events:publish("buildPanel/build", self.buildType)
    Events:publish("buildPanel/hide")
  end
end

return BuildOption
