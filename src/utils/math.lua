local MathUtils = {}

function MathUtils.distance(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return math.sqrt((dx * dx) + (dy * dy))
end

function MathUtils.circularBounds(cx, cy, r, x, y)
  return MathUtils.distance(cx, cy, x, y) <= r
end

function MathUtils.rectBounds(x, y, rx, ry, rw, rh)
  return x >= rx and x <= rx + rw and y >= ry and y <= ry + rh
end

function MathUtils.lerp(a, b, t)
  return a * (1.0 - t) + b * t
end

function MathUtils.lerp2d(x1, y1, x2, y2, t)
  local dx = MathUtils.lerp(x1, x2, t)
  local dy = MathUtils.lerp(y1, y2, t)

  return dx, dy
end

return MathUtils
