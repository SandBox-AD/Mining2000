local state = require("state")
local logger = require("logger")
local config = require("config")

local movement = {}

local function isDanger(name)
  return config.dangerousBlocks[name] == true
end

local function isProtected(name)
  return config.protectedBlocks[name] == true
end

function movement.refuel()
  if turtle.getFuelLevel() == "unlimited" then
    return true
  end

  if turtle.getFuelLevel() >= config.minFuel then
    return true
  end

  logger.warn("Fuel bas: " .. turtle.getFuelLevel())

  for slot = 1, 16 do
    turtle.select(slot)

    if turtle.refuel(0) then
      turtle.refuel()
      logger.info("Fuel actuel: " .. turtle.getFuelLevel())
      return true
    end
  end

  logger.error("Plus de carburant.")
  return false
end

function movement.turnLeft()
  turtle.turnLeft()
  state.dir = (state.dir + 3) % 4
end

function movement.turnRight()
  turtle.turnRight()
  state.dir = (state.dir + 1) % 4
end

function movement.face(direction)
  while state.dir ~= direction do
    movement.turnRight()
  end
end

local function updateForwardPosition()
  if state.dir == 0 then
    state.z = state.z - 1
  elseif state.dir == 1 then
    state.x = state.x + 1
  elseif state.dir == 2 then
    state.z = state.z + 1
  elseif state.dir == 3 then
    state.x = state.x - 1
  end
end

function movement.safeDig()
  local ok, block = turtle.inspect()

  if ok then
    if isDanger(block.name) then
      logger.warn("Bloc dangereux devant: " .. block.name)
      return false
    end

    if isProtected(block.name) then
      return true
    end

    turtle.dig()
  end

  return true
end

function movement.safeDigUp()
  local ok, block = turtle.inspectUp()

  if ok then
    if isDanger(block.name) then
      logger.warn("Bloc dangereux au-dessus: " .. block.name)
      return false
    end

    if isProtected(block.name) then
      return true
    end

    turtle.digUp()
  end

  return true
end

function movement.safeDigDown()
  local ok, block = turtle.inspectDown()

  if ok then
    if isDanger(block.name) then
      logger.warn("Bloc dangereux en-dessous: " .. block.name)
      return false
    end

    if isProtected(block.name) then
      return true
    end

    turtle.digDown()
  end

  return true
end

function movement.forward()
  if not movement.refuel() then
    return false
  end

  if not movement.safeDig() then
    return false
  end

  while not turtle.forward() do
    turtle.attack()
    movement.safeDig()
    sleep(0.2)
  end

  updateForwardPosition()
  return true
end

function movement.up()
  if not movement.refuel() then
    return false
  end

  if not movement.safeDigUp() then
    return false
  end

  while not turtle.up() do
    turtle.attackUp()
    movement.safeDigUp()
    sleep(0.2)
  end

  state.y = state.y + 1
  return true
end

function movement.down()
  if not movement.refuel() then
    return false
  end

  if not movement.safeDigDown() then
    return false
  end

  while not turtle.down() do
    turtle.attackDown()
    movement.safeDigDown()
    sleep(0.2)
  end

  state.y = state.y - 1
  return true
end

return movement