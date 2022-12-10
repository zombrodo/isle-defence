local Colour = require "src.utils.colour"
local MathUtils = require "src.utils.math"
local Fonts = require "src.utils.font"
local ResourceType = require "src.gameplay.resourceType"

local Connector = {}
Connector.__index = Connector

Connector.font = Fonts.upheaval(16)

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

function Connector:getCost()
  if not (self.parent or self.child) then
    return 0
  end

  return math.floor(
    MathUtils.distance(self.parent.x, self.parent.y, self.child.x, self.child.y) / 10
  )
end

function Connector:canConnect(stockpile)
  if not self.parent then
    return true
  end

  local mx, my = Screen:getMousePosition()
  local amount = math.floor(
    MathUtils.distance(self.parent.x, self.parent.y, mx, my) / 10
  )
  return stockpile:has(ResourceType.Rope, amount)
end

function Connector:drawCost(stockpile)
  local mx, my = Screen:getMousePosition()
  local amount = math.floor(
    MathUtils.distance(self.parent.x, self.parent.y, mx, my) / 10
  )

  local halfX, halfY = Screen:toScreen(
    (self.parent.x + mx) / 2, (self.parent.y + my) / 2
  )


  love.graphics.setColor(1, 1, 1)

  love.graphics.draw(
    ResourceType.sprite,
    ResourceType.quad(ResourceType.Rope),
    halfX,
    halfY,
    0,
    4,
    4
  )

  if not stockpile:has(ResourceType.Rope, amount) then
    love.graphics.setColor(1, 0, 0)
  end

  love.graphics.print(amount, Connector.font, halfX + 32, halfY)

end

return Connector
