local Colour = require "src.utils.colour"
local MathUtils = require "src.utils.math"

local Connector = {}
Connector.__index = Connector

Connector.colour = Colour.fromHex("#ad7757")

function Connector.new(physics)
  local self = setmetatable({}, Connector)
  self.physics = physics
  self.parent = nil
  self.child = nil
  self.joint = nil
  return self
end

function Connector:generate()
  self.joint = self.physics:addJoint(
    "DistanceJoint",
    self.parent.body,
    self.child.body,
    self.parent.x,
    self.parent.y,
    self.child.x,
    self.child.y,
    true
  )

  self.joint:setLength(20)
  self.joint:setDampingRatio(0.4)
  self.joint:setFrequency(0.1)
end

function Connector:setParent(parent)
  self.parent = parent
  if self.child then
    self:generate()
  end
end

function Connector:setChild(child)
  self.child = child
  if self.parent then
    self:generate()
  end
end

function Connector:isComplete()
  return self.child and self.parent
end

function Connector:update(dt)
  if self:isComplete() then
    return
  end

  local mx, my = Screen:getMousePosition()
  print(MathUtils.distance(self.parent.x, self.parent.y, mx, my))

end

function Connector:draw()
  love.graphics.push("all")
  love.graphics.setColor(Connector.colour)
  love.graphics.setLineStyle("rough")
  if self:isComplete() then
    love.graphics.line(self.parent.x, self.parent.y, self.child.x, self.child.y)
  else
    local mx, my = Screen:getMousePosition()
    love.graphics.line(self.parent.x, self.parent.y, mx, my)
  end
  love.graphics.pop()
end

return Connector
