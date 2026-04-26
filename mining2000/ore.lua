local ore = {}

function ore.isOre(name)
  if not name then
    return false
  end

  return name:find("ore") ~= nil
      or name:find("ancient_debris") ~= nil
      or name:find("raw_") ~= nil
end

return ore