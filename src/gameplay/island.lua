local Particle = require "src.gameplay.effects.particle"
local Build = require "src.gameplay.build"
local SineGenerator = require "src.utils.sine"
local Math = require "src.utils.math"
local Colour = require "src.utils.colour"

local Island = {}
Island.__index = Island

Island.sprite = love.graphics.newImage("assets/island/island.png")
Island.hovered = love.graphics.newImage("assets/island/highlight.png")

Island.szWidth = 24
Island.szHeight = 8

Island.szX = 4
Island.szY = 10

Island.collHeight = 14
Island.collWidth = 32
Island.collX = 0
Island.collY = 8

Island.towerRange = Colour.fromHex("#253a5e")

Island.guidelineColour = Colour.withAlpha(Colour.fromHex("#222222"), 0.5)

function Island.new(physics, x, y, buildType)
  local self = setmetatable({}, Island)
  self.x = x
  self.y = y
  self.bob = SineGenerator.new(1, 2, true)
  self.build = Build.new(buildType)
  self.physics = physics

  self.body = self.physics:newRectangleCollider(
    (self.x + Island.collX) - Island.sprite:getWidth() / 2,
    (self.y + Island.collY) - Island.sprite:getHeight() / 2,
    Island.collWidth,
    Island.collHeight)

  self.body:setFixedRotation(true)
  self.body:setMass(50)
  self.body:setRestitution(1)
  self.body:setLinearDamping(0.3)
  -- self.body:setFriction(1)

  self.health = 100

  self.smoke = Particle.smoke()
  self.fire = Particle.fire()

  self.hovered = false
  self.connections = {}

  return self
end

function Island:update(dt, isTooltipOpen)
  self.x, self.y = self.body:getPosition()

  self.build:update(dt)

  if isTooltipOpen then
    return
  end

  if self.health < 50 then
    self.smoke:update(dt)
  end

  if self.health <= 0 then
    self.fire:update(dt)
  end

  if Math.circularBounds(self.x, self.y, 16, Screen:getMousePosition()) then
    self.hovered = true
  elseif self.hovered then
    self.hovered = false
  end
end

function Island:attach(connection)
  table.insert(self.connections, connection)
  if not connection.parent then
    connection:setParent(self)
  else
    connection:setChild(self)
  end
end

function Island:detach(connection)
  print(connection)
  for i = #self.connections, 1, -1 do
    if self.connections[i] == connection then
      table.remove(self.connections, i)
    end
  end
end

function Island:currentlySetting()
  for i, connection in ipairs(self.connections) do
    if connection.child == nil then
      return true
    end
  end

  return false
end

function Island:draw()
  love.graphics.push("all")
  love.graphics.translate(0, self.bob:getValue())

  if self.hovered then
    love.graphics.draw(Island.hovered, self.x, self.y, 0, 1, 1, Island.hovered:getWidth() / 2,
      Island.hovered:getHeight() / 2)

    if self.build:isTower() then
      love.graphics.setColor(Colour.withAlpha(Island.towerRange, 0.5))
      love.graphics.circle("fill", self.x, self.y, 120)
      love.graphics.setColor(Island.towerRange)
      love.graphics.circle("line", self.x, self.y, 120)
      love.graphics.setColor(1, 1, 1, 1)
    end
  end

  love.graphics.draw(Island.sprite, self.x, self.y, 0, 1, 1, Island.sprite:getWidth() / 2,
    Island.sprite:getHeight() / 2)

  if self.health < 50 and self.health > 0 then
    self.smoke:draw(
      self.x,
      self.y
    )
  elseif self.health == 0 then
    self.fire:draw(self.x, self.y)
  end

  self.build:draw((self.x + Island.szX) - Island.sprite:getWidth() / 2,
    ((self.y + Island.szY) - Island.sprite:getHeight() / 2) - 8)

  love.graphics.setColor(Colour.withAlpha(Colour.fromHex("#222222"), 0.2))
  love.graphics.ellipse("fill", self.x, self.y + 30, 15, 8)

  for i, connection in ipairs(self.connections) do
    if connection.parent == self then
      connection:draw()
    end
  end

  if self:currentlySetting() then
    love.graphics.setColor(Island.guidelineColour)
    -- love.graphics.circle("line", self.x, self.y, 75)
  end

  love.graphics.pop()
end

return Island
