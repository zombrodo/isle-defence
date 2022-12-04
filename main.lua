love.graphics.setDefaultFilter("nearest", "nearest")

local Pixel = require "lib.pixel"
local Roomy = require "lib.roomy"

local GameScene = require "src.scenes.game"

SceneManager = nil
Screen = nil

DEBUG_MODE = true
GAME_WIDTH = 640
GAME_HEIGHT = 360

function love.load()
  Screen = Pixel.new(
    GAME_WIDTH,
    GAME_HEIGHT,
    love.graphics.getWidth(),
    love.graphics.getHeight()
  )

  SceneManager = Roomy.new()
  SceneManager:hook({ exclude = { "draw" }})
  SceneManager:enter(GameScene.new())
end

function love.update(dt)
end

function love.draw()
  Screen:attach()
  love.graphics.clear()
  SceneManager:emit("draw")
  Screen:detach()
  SceneManager:emit("drawUI")
end

function love.resize()
  Screen:resize()
end

function love.keypressed(key)
  if key == "f5" then
---@diagnostic disable-next-line: param-type-mismatch
    love.event.quit("restart")
  end
end
