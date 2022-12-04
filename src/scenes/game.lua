local Colour = require "src.utils.colour"

local Island = require "src.gameplay.island"

local GameScene = {}
GameScene.__index = GameScene

function GameScene.new()
  local self = setmetatable({}, GameScene)
  self.island = Island.new(GAME_WIDTH / 2, GAME_HEIGHT / 2)
  return self
end

function GameScene:update(dt)

end

function GameScene:draw()
  love.graphics.push("all")
  love.graphics.clear(Colour.Blue)
  self.island:draw()
  love.graphics.pop()
end

return GameScene
