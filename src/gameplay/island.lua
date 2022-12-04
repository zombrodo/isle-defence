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

function Island.new(x, y)
  local self = setmetatable({}, Island)
  self.x = x
  self.y = y
  self.bob = SineGenerator.new(1, 2)
  self.build = Build.new(BuildType.Mine)
  return self
end

function Island:update(dt)

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
