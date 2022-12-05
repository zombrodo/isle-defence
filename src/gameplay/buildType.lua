local BuildType = {}

BuildType.Blank = "build/blank"
BuildType.Farm = "build/farm"
BuildType.House = "build/house"
BuildType.Forest = "build/forest"
BuildType.Woodcutter = "build/woodcutter"
BuildType.Ore = "build/ore"
BuildType.Mine = "build/mine"

local sprites = {
  [BuildType.Farm] = love.graphics.newImage("assets/placement/farm.png"),
  [BuildType.House] = love.graphics.newImage("assets/placement/houses.png"),
  [BuildType.Forest] = love.graphics.newImage("assets/placement/trees.png"),
  [BuildType.Woodcutter] = love.graphics.newImage("assets/placement/woodcutter.png"),
  [BuildType.Ore] = love.graphics.newImage("assets/placement/ore.png"),
  [BuildType.Mine] = love.graphics.newImage("assets/placement/mine.png")
}

function BuildType.sprite(buildType)
  return sprites[buildType]
end

return BuildType
