local Patchy = require "lib.patchy"

local Plan = require "lib.plan"
local Container = Plan.Container

local Font = require "src.utils.font"
local Colour = require "src.utils.colour"
local ResourceType = require "src.gameplay.resourceType"

local font = Font.upheaval(24)

local Resource = Container:extend()

Resource.patch = Patchy.load("assets/ui/panel.9.png")

local function pad(n)
  local p = "00"

  if n >= 10 and n < 100 then
    p = "0"
  end

  if n > 100 then
    p = ""
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
  -- Resource.patch:draw(self.x, self.y, self.w, self.h)
  love.graphics.translate(self.x, self.y)
  love.graphics.draw(self.sprite, self.quad, 0, 0, 0, 6, 6)
  love.graphics.setColor(Colour.fromHex("#202e37"))
  love.graphics.print(pad(self.stockpile:get(self.resourceType)), font, 60, 14, 0, 1, 1, font:getHeight() / 2)
  love.graphics.pop()
end

return Resource
