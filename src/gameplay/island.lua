local BuildType = require "src.gameplay.buildType"
local Build = require "src.gameplay.build"
local SineGenerator = require "src.utils.sine"

local Island = {}
Island.__index = Island

Island.sprite = love.graphics.newImage("assets/island/island.png")

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
  self.bob = SineGenerator.new(1, 2)
  self.build = Build.new(BuildType.None)
  self.physics = physics

  self.body = self.physics:newRectangleCollider(
    (self.x + Island.collX) - Island.sprite:getWidth() / 2,
    (self.y + Island.collY) - Island.sprite:getHeight() / 2,
    Island.collWidth,
    Island.collHeight)

  self.body:setFixedRotation(true)
  self.body:setMass(20)
  self.body:setFriction(0.6)

  return self
end

function Island:update(dt)
  self.x, self.y = self.body:getPosition()
end

function Island:draw()
  love.graphics.push("all")
  love.graphics.translate(0, self.bob:getValue())

  love.graphics.draw(Island.sprite, self.x, self.y, 0, 1, 1, Island.sprite:getWidth() / 2,
    Island.sprite:getHeight() / 2)

  self.build:draw((self.x + Island.szX) - Island.sprite:getWidth() / 2,
    ((self.y + Island.szY) - Island.sprite:getHeight() / 2) - 8)

  love.graphics.pop()
end

return Island
