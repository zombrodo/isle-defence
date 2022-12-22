local Audio = {}

Audio.__cache = {}

function Audio.load(tag, file)
  local src = love.audio.newSource(file, "static")
  Audio.__cache[tag] = src
end

function Audio.play(tag)
  Audio.__cache[tag]:play()
end

return Audio