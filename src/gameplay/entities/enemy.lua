local Colour = require "src.utils.colour"
local SineGenerator = require "src.utils.sine"

local Enemy = {}
Enemy.__index = Enemy

Enemy.sprite = love.graphics.newImage("assets/ships/enemy.png")

function Enemy.new(x, y)
  local self = setmetatable({}, Enemy)
  self.x = x
  self.y = y

  self.bob = SineGenerator.new(1.2, 0.8, true)

  return self
end

function Enemy:update(dt)

end

function Enemy:draw()
  love.graphics.push("all")
  love.graphics.translate(0, self.bob:getValue())
  love.graphics.draw(
    Enemy.sprite,
    self.x,
    self.y,
    0,
    1,
    1,
    Enemy.sprite:getWidth() / 2,
    Enemy.sprite:getHeight() / 2
  )

  love.graphics.setColor(Colour.withAlpha(Colour.fromHex("#222222"), 0.2))
  love.graphics.ellipse("fill", self.x, self.y + 30, 6, 3)
  love.graphics.pop()
end

return Enemy
