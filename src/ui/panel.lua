local Patchy = require "lib.patchy"
local Plan = require "lib.plan"
local Container = Plan.Container

local Panel = Container:extend()

Panel.patch = Patchy.load("assets/ui/panel.9.png")

function Panel:new(rules)
  local panel = Panel.super.new(self, rules)
  return panel
end

function Panel:draw()
  Panel.patch:draw(self.x, self.y, self.w, self.h)
  Panel.super.draw(self)
end

return Panel
