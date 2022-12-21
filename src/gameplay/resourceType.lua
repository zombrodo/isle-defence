local ResourceType = {}

ResourceType.Wood = "resource/wood"
ResourceType.Food = "resource/food"
ResourceType.Ore = "resource/ore"
ResourceType.People = "resource/people"
ResourceType.Rope = "resource/rope"
ResourceType.Villagers = "resource/villagers"

ResourceType.sprite = love.graphics.newImage("assets/resources/resources.png")

local quads = {
  [ResourceType.Wood] = love.graphics.newQuad(
    0, 0, 8, 8, ResourceType.sprite:getWidth(), ResourceType.sprite:getHeight()
  ),
  [ResourceType.Food] = love.graphics.newQuad(
    8, 0, 8, 8, ResourceType.sprite:getWidth(), ResourceType.sprite:getHeight()
  ),
  [ResourceType.Ore] = love.graphics.newQuad(
    0, 8, 8, 8, ResourceType.sprite:getWidth(), ResourceType.sprite:getHeight()
  ),
  [ResourceType.People] = love.graphics.newQuad(
    8, 8, 8, 8, ResourceType.sprite:getWidth(), ResourceType.sprite:getHeight()
  ),
  [ResourceType.Rope] = love.graphics.newQuad(
    16, 0, 8, 8, ResourceType.sprite:getWidth(), ResourceType.sprite:getHeight()
  ),
  [ResourceType.Villagers] = love.graphics.newQuad(
    16, 8, 8, 8, ResourceType.sprite:getWidth(), ResourceType.sprite:getHeight()
  )
}

function ResourceType.quad(resourceType)
  return quads[resourceType]
end

local names = {
  [ResourceType.Wood] = "Wood",
  [ResourceType.Food] = "Food",
  [ResourceType.Ore] = "Ore",
  [ResourceType.People] = "Workers",
  [ResourceType.Rope] = "Rope",
  [ResourceType.Villagers] = "Villagers"
}

function ResourceType.displayName(resourceType)
  return names[resourceType]
end

return ResourceType
