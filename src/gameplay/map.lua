local Map = {}
Map.__index = Map

function Map.new()
  local self = setmetatable({}, Map)
  self.islands = {}
  return self
end

function Map:update(dt)

end

function Map:draw()
  love.graphics.push("all")
  love.graphics.pop()
end

return Map
