local Plan = require "lib.plan"
local Container = Plan.Container

local Font = require "src.utils.font"
local Colour = require "src.utils.colour"
local ResourceType = require "src.gameplay.resourceType"

local font = Font.upheaval(28)

local Resource = Container:extend()

local function pad(n)
  local p = "00"

  if n >= 10 and n < 100 then
    p = "0"
  end

  return p .. tostring(n)
end

function Resource:new(rules, stockpile, resourceType)
  local resource = Resource.super.new(self, rules)
  resource.resourceType = resourceType
  resource.quad = ResourceType.quad(resourceType)
  resource.sprite = ResourceType.sprite
  resource.stockpile = stockpile
  return resource
end

function Resource:draw()
  Resource.super.draw(self)
  love.graphics.push("all")
  love.graphics.translate(self.x, self.y)
  love.graphics.draw(self.sprite, self.quad, 0, 0, 0, 6, 6)
  love.graphics.print(pad(self.stockpile:get(self.resourceType)), font, 80, 10, 0, 1, 1, font:getHeight())
  love.graphics.pop()
end

return Resource
