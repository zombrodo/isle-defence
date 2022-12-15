local ResourceType = require "src.gameplay.resourceType"

local BuildType = {}

BuildType.None = "build/none"
BuildType.Farm = "build/farm"
BuildType.House = "build/house"
BuildType.Forest = "build/forest"
BuildType.Woodcutter = "build/woodcutter"
BuildType.Ore = "build/ore"
BuildType.Mine = "build/mine"
BuildType.Hemp = "build/hemp"
BuildType.Tower = "build/tower"

local sprites = {
  [BuildType.Farm] = love.graphics.newImage("assets/placement/farm.png"),
  [BuildType.House] = love.graphics.newImage("assets/placement/houses.png"),
  [BuildType.Forest] = love.graphics.newImage("assets/placement/trees.png"),
  [BuildType.Woodcutter] = love.graphics.newImage("assets/placement/woodcutter.png"),
  [BuildType.Ore] = love.graphics.newImage("assets/placement/ore.png"),
  [BuildType.Mine] = love.graphics.newImage("assets/placement/mine.png"),
  [BuildType.Hemp] = love.graphics.newImage("assets/placement/hemp.png"),
  [BuildType.Tower] = love.graphics.newImage("assets/placement/tower.png")
}

local spawnableLocations = {
  BuildType.None,
  BuildType.None,
  BuildType.None,
  BuildType.None,
  BuildType.Forest,
  BuildType.Forest,
  BuildType.Forest,
  BuildType.Ore,
  BuildType.Ore,
}

local costs = {
  [BuildType.Farm] = {
    [ResourceType.Wood] = 10,
    [ResourceType.People] = 2
  },
  [BuildType.Hemp] = {
    [ResourceType.Wood] = 10,
    [ResourceType.People] = 2
  },
  [BuildType.Mine] = {
    [ResourceType.Wood] = 10,
    [ResourceType.People] = 3
  },
  [BuildType.Woodcutter] = {
    [ResourceType.Wood] = 10,
    [ResourceType.People] = 3
  },
  [BuildType.House] = {
    [ResourceType.Wood] = 20,
    [ResourceType.Ore] = 5
  },
  [BuildType.Tower] = {
    [ResourceType.Ore] = 10,
    [ResourceType.Wood] = 10,
    [ResourceType.People] = 5,
  }
}

function BuildType.cost(buildType)
  return costs[buildType]
end

function BuildType.randomSpawn()
  return spawnableLocations[love.math.random(1, #spawnableLocations)]
end

local health = {
  [BuildType.Farm] = true,
  [BuildType.Hemp] = true,
  [BuildType.Tower] = true,
  [BuildType.House] = true,
  [BuildType.Woodcutter] = true,
  [BuildType.Mine] = true
}

function BuildType.hasHealth(buildType)
  return health[buildType] == true
end

function BuildType.sprite(buildType)
  return sprites[buildType]
end

function BuildType.produce(buildType)
  if buildType == BuildType.Woodcutter then
    return ResourceType.Wood, 1
  end

  if buildType == BuildType.Hemp then
    return ResourceType.Rope, 1
  end

  if buildType == BuildType.Farm then
    return ResourceType.Food, 1
  end

  if buildType == BuildType.Mine then
    return ResourceType.Ore, 1
  end

  return nil, nil
end

local names = {
  [BuildType.None] = "None",
  [BuildType.Farm] = "Farm",
  [BuildType.House] = "Houses",
  [BuildType.Forest] = "Forest",
  [BuildType.Woodcutter] = "Woodcutter",
  [BuildType.Ore] = "Ore",
  [BuildType.Mine] = "Mine",
  [BuildType.Hemp] = "Hemp Farm",
  [BuildType.Tower] = "Tower"
}

function BuildType.displayName(buildType)
  return names[buildType]
end

return BuildType
