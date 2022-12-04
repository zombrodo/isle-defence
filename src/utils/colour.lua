local Colour = {}

Colour.__cache = {}

Colour.withAlpha = function(colour, alpha)
  return { colour[1], colour[2], colour[3], alpha }
end

Colour.fromHex = function(hex, alpha)
  if #hex == 7 then
    hex = string.sub(hex, 2)
  end

  if Colour.__cache[hex] then
    if alpha then
      return Colour.withAlpha(Colour.__cache[hex], alpha)
    end

    return Colour.__cache[hex]
  end

  local colour = {
    (1 / 255) * tonumber(string.sub(hex, 1, 2), 16),
    (1 / 255) * tonumber(string.sub(hex, 3, 4), 16),
    (1 / 255) * tonumber(string.sub(hex, 5, 6), 16)
  }

  Colour.__cache[hex] = colour

  if alpha then
    return Colour.withAlpha(colour, alpha)
  end

  return colour
end

return Colour
