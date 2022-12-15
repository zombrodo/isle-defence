local Font = {}
Font.__cache = {}

function Font.register(id, path)
  if Font.__cache[id] then
    return
  end

  Font.__cache[id] = {}

  Font[id] = function(size)
    if Font.__cache[id][size] then
      return Font.__cache[id][size]
    end

    local font = love.graphics.newFont(path, size)
    Font.__cache[id][size] = font
    return font
  end
end

Font.register("upheaval", "assets/fonts/upheaval.ttf")

return Font
