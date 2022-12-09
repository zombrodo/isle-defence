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

function MathUtils.findAngle(fromX, fromY, toX, toY)
  return -math.atan2(toX - fromX, toY - fromY)
end

function MathUtils.findMidpoint(rx, ry, rw, rh)
  return rx + rw / 2, ry + ry / 2
end

function MathUtils.rectangleEdge(width, height, angle)
  local full = 2 * math.pi

  while angle < -math.pi do
    angle = angle + full
  end


  while angle > math.pi do
    angle = angle - full
  end

  local rectAtan = math.atan2(height, width)
  local tanTheta = math.tan(angle)

  local region = 4

  if angle > -rectAtan and angle <= rectAtan then
    region = 1
  end

  if angle > rectAtan and angle <= (math.pi - rectAtan) then
    region = 2
  end

  if angle > (math.pi - rectAtan) or angle <= -(math.pi - rectAtan) then
    region = 3
  end

  local edgeX = width / 2
  local edgeY = height / 2

  local xFactor = 1
  local yFactor = 1

  if region == 1 or region == 2 then
    yFactor = -1
  end

  if region == 3 or region == 4 then
    xFactor = -1
  end

  if region == 1 or region == 3 then
    edgeX = edgeX + xFactor * (width / 2)
    edgeY = edgeY + yFactor * (width / 2) * tanTheta
  else
    edgeX = edgeX + xFactor * (height / (2 * tanTheta))
    edgeY = edgeY + yFactor * (height / 2)
  end

  return edgeX, edgeY
end

return MathUtils
