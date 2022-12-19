love.graphics.setDefaultFilter("nearest", "nearest")

local Pixel = require "lib.pixel"
local Roomy = require "lib.roomy"
Flux = require "lib.flux"

local GameScene = require "src.scenes.game"
local DebugScene = require "src.scenes.debug"

local PubSub = require "src.utils.pubsub"

Events = nil

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

  Events = PubSub.new()

  SceneManager = Roomy.new()
  SceneManager:hook({ exclude = { "draw" } })
  SceneManager:enter(GameScene.new())
end

function love.update(dt)
  Flux.update(dt)
end

function love.draw()
  Screen:attach()
  love.graphics.clear()
  SceneManager:emit("draw")
  Screen:detach()
  SceneManager:emit("drawUI")

  -- if DEBUG_MODE then
  --   love.graphics.setColor(0, 0, 0)
  --   love.graphics.rectangle('fill', 0, 0, 256, 64)
  --   love.graphics.setColor(1, 1, 1)
  --   love.graphics.print('FPS: ' .. love.timer.getFPS(), 0, 0)
  --   love.graphics.print('Memory: ' .. math.floor(collectgarbage 'count') .. ' kb', 0, 16)
  -- end
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
