local Windfield = require "lib.windfield"

local Colour = require "src.utils.colour"
local Island = require "src.gameplay.island"

local GameScene = {}
GameScene.__index = GameScene

function GameScene.new()
  local self = setmetatable({}, GameScene)
  self.physics = Windfield.newWorld(0, 0)
  self.islands = {}
  for i = 1, 10 do
    table.insert(self.islands, Island.new(self.physics, GAME_WIDTH / 2, GAME_HEIGHT / 2))
  end
  return self
end

function GameScene:update(dt)
  self.physics:update(dt)
  for i, elem in ipairs(self.islands) do
    elem:update(dt)
  end
end

function GameScene:draw()
  love.graphics.push("all")
  love.graphics.clear(Colour.Blue)
  for i, elem in ipairs(self.islands) do
    elem:draw()
  end
  love.graphics.pop()
end

return GameScene
