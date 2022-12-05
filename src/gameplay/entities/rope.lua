local Colour = require "src.utils.colour"
local Math = require "src.utils.math"

local Rope = {}
Rope.__index = Rope

Rope.colour = Colour.fromHex("#ad7757")

function Rope.new(physics)
  local self = setmetatable({}, Rope)
  self.from = nil
  self.to = nil
  self.physics = physics

  self.bodies = {}

  return self
end

function Rope:generate()
  local complete = self.from and self.to
  if complete then
    local length = Math.distance(
      self.from.x, self.from.y, self.to.x, self.to.y
    )

    local toCreate = math.floor(length / 10)

    local root = self.physics:newCircleCollider(self.from.x, self.from.y, 1)
    self.physics:addJoint("WeldJoint", root, self.from.body, self.from.x, self.from.y, false)

    local bodies = {
      root
    }

    for i = 2, toCreate do
      local x, y = Math.lerp2d(
        self.from.x, self.from.y, self.to.x, self.to.y, 1
      )

      local new = self.physics:newCircleCollider(x, y, 1)
      local previous = bodies[i - 1]
      local px, py = previous:getPosition()

      self.physics:addJoint("RopeJoint", new, previous, x, y, px, py, 5, false)
      table.insert(bodies, new)
    end

    local final = self.physics:newCircleCollider(self.to.x, self.to.y, 1)
    self.physics:addJoint("WeldJoint", final, self.to.body, self.to.x, self.to.y, false)

    local second = bodies[#bodies]
    local sx, sy = final:getPosition()

    self.physics:addJoint(
      "RopeJoint", final, second, self.to.x, self.to.y, sx, sy, 1, false
    )

    table.insert(bodies, final)
    self.bodies = bodies
  end
end

function Rope:update(dt)
end

function Rope:setFrom(island)
  self.from = island
  if self.from and self.to then
    self:generate()
  end
end

function Rope:setTo(island)
  self.to = island
  if self.to and self.from then
    self:generate()
  end
end

function Rope:clear()
  if self.from then
    self.from.connection = nil
    self.from = nil
  end

  if self.to then
    self.to.connection = nil
    self.to = nil
  end

  for i, body in ipairs(self.bodies) do
    body:destroy()
  end
end

function Rope:canSet(island)
  if self:isAttachedTo(island) then
    return false
  end

  local source = self.from or self.to
  if not source then
    return true
  end

  return true
end

function Rope:isAttachedTo(island)
  return self.to == island or self.from == island
end

function Rope:draw()
  love.graphics.push("all")
  love.graphics.setColor(Rope.colour)
  if self.from and self.to then
    -- love.graphics.line(self.from.x, self.from.y, self.to.x, self.to.y)
    for i = 1, #self.bodies - 1 do
      local ax, ay = self.bodies[i]:getPosition()
      local bx, by = self.bodies[i + 1]:getPosition()

      love.graphics.line(ax, ay, bx, by)
    end
  else
    local source = self.from or self.to
    local mx, my = Screen:getMousePosition()
    love.graphics.line(source.x, source.y, mx, my)
  end
  love.graphics.pop()
end

return Rope
