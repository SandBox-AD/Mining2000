local config = require("config")
local logger = require("logger")

local inventory = {}

function inventory.isFull()
  for slot = 1, 16 do
    if turtle.getItemCount(slot) == 0 then
      return false
    end
  end

  return true
end

function inventory.dropTrash()
  logger.info("Nettoyage inventaire...")

  for slot = 1, 16 do
    turtle.select(slot)

    local item = turtle.getItemDetail()
    if item and config.trash[item.name] then
      turtle.dropDown()
    end
  end

  turtle.select(1)
end

function inventory.needCleaning()
  return inventory.isFull()
end

return inventory