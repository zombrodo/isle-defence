local Json = require "lib.json"

local Settings = {}

Settings.__location = "settings.json"
Settings.__content = {}

function Settings.load()
  local info = love.filesystem.getInfo(Settings.__location, "file")
  if info then
    local contents, err = love.filesystem.read(Settings.__location)
    if contents then
      Settings.__content = Json.decode(contents)
    end
  end
end

function Settings.save()
  local str = Json.encode(Settings.__content)
  local success, message = love.filesystem.write(Settings.__location, str)
  if not success then
    print(message)
  end
end

function Settings.set(opt, value)
  Settings.__content[opt] = value
end

function Settings.get(opt)
  return Settings.__content[opt]
end

return Settings
