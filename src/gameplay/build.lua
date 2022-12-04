local BuildType = require "src.gameplay.buildType"

local Build = {}
Build.__index = Build

function Build.new(buildType)
  local self = setmetatable({}, Build)
  self.buildType = buildType
  return self
end

function Build:update(dt)

end

function Build:draw(x, y, r)
  love.graphics.push("all")
  love.graphics.draw(BuildType.sprite(self.buildType), x, y, r)
  love.graphics.pop()
end

return Build
