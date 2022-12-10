local Set = {}
Set.__index = Set

function Set.new()
  local self = setmetatable({}, Set)
  self.items = {}
  return self
end

function Set:add(item)
  self.items[item] = item
end

function Set:contains(item)
  return self.items[item] ~= nil
end

return Set
