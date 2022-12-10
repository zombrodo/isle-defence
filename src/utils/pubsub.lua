local PubSub = {}
PubSub.__index = PubSub

local function remove(tbl, item)
  for i = #tbl, 1, -1 do
    if tbl[i] == item then
      table.remove(tbl, i)
    end
  end
end

function PubSub.new()
  local self = setmetatable({}, PubSub)
  self.subscriptions = {}
  return self
end

function PubSub:publish(event, ...)
  local callbacks = self.subscriptions[event]
  if callbacks then
    for i, elem in ipairs(callbacks) do
      elem(...)
    end
  end
end

function PubSub:subscribe(event, callback)
  local callbacks = self.subscriptions[event]
  if not callbacks then
    self.subscriptions[event] = {}
  end

  table.insert(self.subscriptions[event], callback)
end

function PubSub:unsubscribe(event, callback)
  local callbacks = self.subscriptions[event]
  if callbacks then
    remove(callbacks, callback)
  end
end

return PubSub
