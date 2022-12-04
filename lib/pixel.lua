local Pixel = {}
Pixel.__index = Pixel

function Pixel.new(gameWidth, gameHeight, windowWidth, windowHeight)
  local self = setmetatable({}, Pixel)
  self.gameWidth = gameWidth
  self.gameHeight = gameHeight
  self.windowWidth = windowWidth
  self.windowHeight = windowHeight

  self.canvas = love.graphics.newCanvas(gameWidth, gameHeight)

  self.scaleX = 1
  self.scaleY = 1

  self:initialise()
  return self
end

function Pixel:initialise()
  local pixelScale = love.window.getDPIScale()

  self.scaleX = self.windowWidth / self.gameWidth * pixelScale
  self.scaleY = self.windowHeight / self.gameHeight * pixelScale

  local scale = math.min(self.scaleX, self.scaleY)

  self.offsetX = (self.scaleX - scale) * (self.gameWidth / 2)
  self.offsetY = (self.scaleY - scale) * (self.gameHeight / 2)

  self.scaleX = scale
  self.scaleY = scale

  self.__worldWidth = self.windowWidth * pixelScale - self.offsetX * 2
  self.__worldHeight = self.windowHeight * pixelScale - self.offsetY * 2
end

function Pixel:attach()
  love.graphics.push("all")
  love.graphics.setCanvas(self.canvas)
end

function Pixel:detach()
  love.graphics.pop()
  self:draw()
end

function Pixel:draw()
  love.graphics.push("all")
  love.graphics.translate(self.offsetX, self.offsetY)
  love.graphics.scale(self.scaleX, self.scaleY)
  love.graphics.draw(self.canvas)
  love.graphics.pop()
end

function Pixel:toScreen(gx, gy)
  local screenX = self.offsetX + (self.__worldWidth * gx) / self.gameWidth
  local screenY = self.offsetY + (self.__worldHeight * gy) / self.gameHeight

  return screenX, screenY
end

function Pixel:toGame(sx, sy)
  local x = sx - self.offsetX
  local y = sy - self.offsetY

  local normalX = x / self.__worldWidth
  local normalY = y / self.__worldHeight

  local resultX = nil
  local resultY = nil

  if x >= 0 and x <= self.gameWidth * self.scaleX then
    resultX = normalX * self.gameWidth
  end

  if y >= 0 and y <= self.gameHeight * self.scaleY then
    resultY = normalY * self.gameHeight
  end

  return resultX, resultY
end

function Pixel:getMousePosition()
  local mx, my = love.mouse.getPosition()
  return self:toGame(mx, my)
end

function Pixel:resize()
  self.windowWidth = love.graphics.getWidth()
  self.windowHeight = love.graphics.getHeight()
  self:initialise()
end

return Pixel
