local BuildType = require "src.gameplay.buildType"
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

function Island.new(physics, x, y)
  local self = setmetatable({}, Island)
  self.x = x
  self.y = y
  self.bob = SineGenerator.new(1, 2, true)
  self.build = Build.new(BuildType.rando())
  self.physics = physics

  self.body = self.physics:newRectangleCollider(
    (self.x + Island.collX) - Island.sprite:getWidth() / 2,
    (self.y + Island.collY) - Island.sprite:getHeight() / 2,
    Island.collWidth,
    Island.collHeight)

  self.body:setFixedRotation(true)
  self.body:setMass(50)
  self.body:setRestitution(0.05)
  self.body:setLinearDamping(0.3)
  -- self.body:setFriction(1)

  self.hovered = false

  return self
end

function Island:update(dt)
  self.x, self.y = self.body:getPosition()
  if Math.circularBounds(self.x, self.y, 16, Screen:getMousePosition()) then
    self.hovered = true
  else
    self.hovered = false
  end
end

function Island:attach(rope)
  self.connection = rope

  if not rope.from then
    rope:setFrom(self)
    return
  end

  if not rope.to then
    rope:setTo(self)
    return
  end
end

function Island:detach()
  if self.connection.from == self then
    self.connection:setFrom(nil)
  end

  if self.connection.to == self then
    self.connection:setTo(nil)
  end

  self.connection = nil
end

function Island:draw()
  love.graphics.push("all")
  love.graphics.translate(0, self.bob:getValue())

  if self.hovered then
    love.graphics.draw(Island.hovered, self.x, self.y, 0, 1, 1, Island.hovered:getWidth() / 2,
      Island.hovered:getHeight() / 2)
  end

  love.graphics.draw(Island.sprite, self.x, self.y, 0, 1, 1, Island.sprite:getWidth() / 2,
    Island.sprite:getHeight() / 2)

  self.build:draw((self.x + Island.szX) - Island.sprite:getWidth() / 2,
    ((self.y + Island.szY) - Island.sprite:getHeight() / 2) - 8)


  love.graphics.setColor(Colour.withAlpha(Colour.fromHex("#222222"), 0.2))
  love.graphics.ellipse("fill", self.x, self.y + 30, 15, 8)

  if self.connection then
    self.connection:draw()
  end

  love.graphics.pop()
end

return Island
