local Patchy = require "lib.patchy"
local Plan = require "lib.plan"
local Container = Plan.Container

local BuildType = require "src.gameplay.buildType"
local ResourceType = require "src.gameplay.resourceType"
local Island = require "src.gameplay.island"

local Colour = require "src.utils.colour"

local Font = require "src.utils.font"

local BuildButton = Container:extend()

BuildButton.patch = Patchy.load("assets/ui/panel.9.png")
BuildButton.titleFont = Font.upheaval(18)

function BuildButton:new(rules, buildType, stockpile)
  local button = BuildButton.super.new(self, rules)
  button.buildType = buildType
  button.sprite = BuildType.sprite(buildType)
  button.stockpile = stockpile

  button.buildName = string.lower(BuildType.displayName(buildType))
  button.cost = BuildType.cost(buildType)

  return button
end

function BuildButton:__islandIcon(islandX, islandY)
  love.graphics.draw(
    Island.sprite,
    islandX,
    islandY,
    0,
    2,
    2,
    Island.sprite:getWidth() / 2,
    Island.sprite:getHeight() / 2
  )

  love.graphics.draw(self.sprite,
    (islandX + Island.szX * 2) - Island.sprite:getWidth(),
    ((islandY + Island.szY * 2) - Island.sprite:getHeight()) - 16,
    0,
    2,
    2,
    Island.szWidth / 2,
    Island.szHeight / 2
  )
end

function BuildButton:__resources(x, y)
  local font = Font.upheaval(16)
  local i = 0
  for resource, amount in pairs(self.cost) do
    love.graphics.draw(
      ResourceType.sprite,
      ResourceType.quad(resource),
      x,
      y,
      0,
      2,
      2
    )

    if not self.stockpile:has(resource, amount) then
      love.graphics.setColor(Colour.fromHex("#a53030"))
    else
      love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.print(amount, font, x + 18, y)
    y = y + 16

    i = i + 1
    if i == 2 then
      x = x + BuildButton.titleFont:getWidth("woodcutter") / 2
      y = y - 32
    end
  end
end

function BuildButton:draw()
  love.graphics.push("all")
  -- love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

  BuildButton.patch:draw(self.x, self.y, self.w, self.h)

  local islandX = self.x + (Island.sprite:getWidth() + 10)
  local islandY = (self.y + (self.h / 2)) - 5

  -- Island
  self:__islandIcon(islandX, islandY)

  -- Title
  love.graphics.print(self.buildName, BuildButton.titleFont, islandX + Island.sprite:getWidth() + 10, self.y + 10)

  -- Cost
  self:__resources(islandX + Island.sprite:getWidth() + 9, islandY)

  BuildButton.super.draw(self)
  love.graphics.pop()
end

return BuildButton
