local Rope = {}
Rope.__index = Rope

function Rope.new()
  local self = setmetatable({}, Rope)
  return self
end

function Rope:update(dt)

end

function Rope:draw()
  love.graphics.push("all")
  love.graphics.pop()
end

return Rope
