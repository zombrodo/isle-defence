local ResourceType = require "src.gameplay.resourceType"

local Stockpile = {}
Stockpile.__index = Stockpile

function Stockpile.new()
  local self = setmetatable({}, Stockpile)
  self.stock = {
    [ResourceType.Wood] = 20,
    [ResourceType.Food] = 50,
    [ResourceType.Ore] = 0,
    [ResourceType.People] = 10,
    [ResourceType.Rope] = 30
  }

  Events:subscribe("stockpile/add", function(resource, amount)
    self:add(resource, amount)
  end)

  return self
end

function Stockpile:get(resource)
  return self.stock[resource]
end

function Stockpile:add(resource, amount)
  self.stock[resource] = self.stock[resource] + amount
end

function Stockpile:has(resource, amount)
  return self.stock[resource] - amount >= 0
end

function Stockpile:remove(resource, amount)
  self.stock[resource] = self.stock[resource] - amount
end

return Stockpile
