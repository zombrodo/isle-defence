local BuildType = require "src.gameplay.buildType"

local Build = {}
Build.__index = Build

function Build.new(buildType)
  local self = setmetatable({}, Build)
  self.buildType = buildType
  self.resourceType, self.amount = BuildType.produce(buildType)
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

function Build:draw(x, y, r)
  love.graphics.push("all")
  if self.buildType ~= BuildType.None then
    love.graphics.draw(BuildType.sprite(self.buildType), x, y, r)
  end
  love.graphics.pop()
end

return Build
