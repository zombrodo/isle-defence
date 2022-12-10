local BuildType = require "src.gameplay.buildType"
local Tower = require "src.gameplay.entities.tower"

local Build = {}
Build.__index = Build

function Build.new(buildType, island)
  local self = setmetatable({}, Build)
  self.buildType = buildType
  self.resourceType, self.amount = BuildType.produce(buildType)
  if buildType == BuildType.Tower then
    self.tower = Tower.new(island)
  end
  self.every = 1
  self.timer = 0
  return self
end

function Build:update(dt)
  if self.resourceType then
    self.timer = self.timer + dt
    if self.timer >= self.every then
      self.timer = 0
      Events:publish("stockpile/add", self.resourceType, self.amount)
    end
  end
end

function Build:isTower()
  return self.buildType == BuildType.Tower
end

function Build:getTower()
  return self.tower
end

function Build:draw(x, y, r)
  love.graphics.push("all")
  if self.buildType ~= BuildType.None then
    love.graphics.draw(BuildType.sprite(self.buildType), x, y, r)
  end

  if self.buildType == BuildType.Tower then
    self.tower:draw()
  end

  love.graphics.pop()
end

return Build
