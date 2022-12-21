local DashedCircle = {}
DashedCircle.__index = DashedCircle

function DashedCircle.new(n)
  local self = setmetatable({}, DashedCircle)
  self.n = n
  return self
end

function DashedCircle:draw(x, y, r)
  local k = 0
  local step = 2 * math.pi / self.n
  for i = 0, 2 * math.pi, step do
    if k % 2 == 0 then
      love.graphics.arc("line", "open", x, y, r, i, i + step)
    end
    k = k + 1
  end
end

return DashedCircle