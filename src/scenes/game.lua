local Windfield = require "lib.windfield"

local Colour = require "src.utils.colour"
local Island = require "src.gameplay.island"

local GameScene = {}
GameScene.__index = GameScene

function GameScene.new()
  local self = setmetatable({}, GameScene)
  self.physics = Windfield.newWorld(0, 0)
  self.island = Island.new(self.physics, GAME_WIDTH / 2, GAME_HEIGHT / 2)
  local mx, my = Screen:getMousePosition()
  self.mover = self.physics:newCircleCollider(mx, my, 5)
  self.joint = self.physics:addJoint("MouseJoint", self.mover, mx, my)
  return self
end

function GameScene:update(dt)
  self.physics:update(dt)
  self.island:update(dt)
  self.joint:setTarget(Screen:getMousePosition())
end

function GameScene:draw()
  love.graphics.push("all")
  love.graphics.clear(Colour.Blue)
  self.island:draw()
  -- self.physics:draw()
  love.graphics.pop()
end

return GameScene
