local Particle = require "src.gameplay.effects.particle"
local Build = require "src.gameplay.build"
local SineGenerator = require "src.utils.sine"
local Math = require "src.utils.math"
local Colour = require "src.utils.colour"
local DashedCircle = require "src.utils.dashedCircle"

local Island = {}
Island.__index = Island

Island.sprite = love.graphics.newImage("assets/island/island.png")
Island.hovered = love.graphics.newImage("assets/island/highlight.png")

Island.szWidth = 24
Island.szHeight = 8

Island.szX = 4 + Island.szWidth / 2
Island.szY = 10 + Island.szHeight / 2

Island.collHeight = 14
Island.collWidth = 32
Island.collX = 0
Island.collY = 8

Island.towerRange = Colour.fromHex("#253a5e")

Island.guidelineColour = Colour.withAlpha(Colour.fromHex("#202e37"), 0.5)

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

  self.connections = {}

  self.fadeOut = false
  self.fade = nil
  self.opacity = 1
  self.shouldRemove = false
  self.static = false

  self.range = DashedCircle.new(60)

  self.creationTime = love.timer.getTime()

  return self
end

function Island:release()
  self.body:destroy()
end

function Island:update(dt, isTooltipOpen)

  if not self.static then
    if love.timer.getTime() - self.creationTime >= 10
        and #self.connections == 0
        and not self.fadeOut
    then
      self.fadeOut = true
      self.fade = Flux.to(self, 3, { opacity = 0 }):oncomplete(function()
        self.shouldRemove = true
      end)
    end

    if self.fadeOut and self.fade and #self.connections > 0 then
      self.opacity = 1
      self.fadeOut = false
      self.fade:stop()
    end
  end

  self.x, self.y = self.body:getPosition()

  if self.health > 0 then
    self.build:update(dt, self.health)
  end

  if isTooltipOpen then
    return
  end

  if self.health < 50 then
    self.smoke:update(dt)
  end

  if self.health <= 0 then
    self.fire:update(dt)
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

function Island:collides(x, y)
  return Math.rectBounds(x, y,
    (self.x + Island.collX) - Island.sprite:getWidth() / 2,
    (self.y + Island.collY) - Island.sprite:getHeight() / 2,
    Island.collWidth,
    Island.collHeight)
end

function Island:damage(amount)
  self.health = self.health - amount
  if self.health < 0 then
    self.health = 0
  end
end

function Island:detach(connection)
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

function Island:draw(isHovered)
  love.graphics.push("all")
  love.graphics.translate(0, self.bob:getValue())
  love.graphics.setColor(1, 1, 1, self.opacity)

  if isHovered then
    love.graphics.draw(Island.hovered, self.x, self.y, 0, self.opacity, self.opacity, Island.hovered:getWidth() / 2,
      Island.hovered:getHeight() / 2)

    if self.build:isTower() then
      love.graphics.setColor(Colour.withAlpha(Island.towerRange, 0.5))
      love.graphics.circle("fill", self.x, self.y, 120)
      love.graphics.setColor(Island.towerRange)
      self.range:draw(self.x, self.y, 120)
      love.graphics.setColor(1, 1, 1, 1)
    end
  end

  love.graphics.draw(Island.sprite, self.x, self.y, 0, self.opacity, self.opacity, Island.sprite:getWidth() / 2,
    Island.sprite:getHeight() / 2)

  if self.health < 50 and self.health > 0 then
    self.smoke:draw(
      self.x,
      self.y
    )
  elseif self.health == 0 then
    self.fire:draw(self.x, self.y)
  end

  self.build:draw(
    (self.x + Island.szX) - Island.sprite:getWidth() / 2,
    ((self.y + Island.szY) - Island.sprite:getHeight() / 2) - 8, 0, self.opacity, self.opacity, Island.szWidth / 2,
    Island.szHeight / 2)

  love.graphics.setColor(Colour.withAlpha(Colour.fromHex("#202e37"), 0.2 * self.opacity))
  love.graphics.ellipse("fill", self.x, self.y + 30, 15 * self.opacity, 8 * self.opacity)

  for i, connection in ipairs(self.connections) do
    if connection.parent == self then
      connection:draw()
    end
  end

  if self:currentlySetting() then
    love.graphics.setColor(Island.guidelineColour)
    -- love.graphics.circle("line", self.x, self.y, 75)
  end

  if isHovered and self.build:hasHealth() then
    love.graphics.setColor(Colour.fromHex("#202e37"))
    love.graphics.rectangle(
      "fill",
      (self.x - Island.sprite:getWidth() / 2) - 1,
      self.y - 21,
      Island.sprite:getWidth() + 2,
      6
    )
    love.graphics.setColor(Colour.fromHex("#a53030"))
    love.graphics.rectangle(
      "fill",
      self.x - Island.sprite:getWidth() / 2,
      self.y - 20,
      Island.sprite:getWidth(),
      4
    )
    love.graphics.setColor(Colour.fromHex("#a8ca58"))
    love.graphics.rectangle(
      "fill",
      self.x - Island.sprite:getWidth() / 2,
      self.y - 20,
      (self.health / 100) * Island.sprite:getWidth(),
      4
    )
  end

  love.graphics.pop()
end

return Island
