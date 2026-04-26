local config = require("config")
local logger = require("logger")
local movement = require("movement")
local inventory = require("inventory")
local ore = require("ore")
local state = require("state")

local miner = {}

local function back()
  movement.turnRight()
  movement.turnRight()
  movement.forward()
  movement.turnRight()
  movement.turnRight()
end

local function placeTorch()
  if not config.placeTorches then
    return false
  end

  local torchSlot = nil

  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)

    if item and item.name == config.torchItem then
      torchSlot = slot
      break
    end
  end

  if not torchSlot then
    logger.warn("Plus de torches, on continue.")
    return false
  end

  turtle.select(torchSlot)

  local startDir = state.dir

  movement.turnRight()
  if turtle.place() then
    movement.face(startDir)
    turtle.select(1)
    logger.info("Torche posee mur droit.")
    return true
  end

  movement.face(startDir)

  movement.turnLeft()
  if turtle.place() then
    movement.face(startDir)
    turtle.select(1)
    logger.info("Torche posee mur gauche.")
    return true
  end

  movement.face(startDir)

  if turtle.placeDown() then
    turtle.select(1)
    logger.info("Torche posee au sol.")
    return true
  end

  turtle.select(1)
  logger.warn("Impossible de poser une torche.")
  return false
end

local function mineConnectedOre(depth)
  depth = depth or 0

  if depth > 32 then
    logger.warn("Veine trop grande, stop securite.")
    return
  end

  local okFront, blockFront = turtle.inspect()
  if okFront and ore.isOre(blockFront.name) then
    turtle.dig()
    if movement.forward() then
      mineConnectedOre(depth + 1)
      back()
    end
  end

  local okUp, blockUp = turtle.inspectUp()
  if okUp and ore.isOre(blockUp.name) then
    turtle.digUp()
    if movement.up() then
      mineConnectedOre(depth + 1)
      movement.down()
    end
  end

  local okDown, blockDown = turtle.inspectDown()
  if okDown and ore.isOre(blockDown.name) then
    turtle.digDown()
    if movement.down() then
      mineConnectedOre(depth + 1)
      movement.up()
    end
  end

  local startDir = state.dir

  movement.turnLeft()
  local okLeft, blockLeft = turtle.inspect()
  if okLeft and ore.isOre(blockLeft.name) then
    turtle.dig()
    if movement.forward() then
      mineConnectedOre(depth + 1)
      back()
    end
  end
  movement.face(startDir)

  movement.turnRight()
  local okRight, blockRight = turtle.inspect()
  if okRight and ore.isOre(blockRight.name) then
    turtle.dig()
    if movement.forward() then
      mineConnectedOre(depth + 1)
      back()
    end
  end
  movement.face(startDir)
end

function miner.mineStep(stepIndex)
  movement.safeDigUp()

  if not movement.forward() then
    return false
  end

  movement.safeDigUp()
  mineConnectedOre()

  if stepIndex and config.torchSpacing > 0 and stepIndex % config.torchSpacing == 0 then
    placeTorch()
  end

  if inventory.needCleaning() then
    inventory.dropTrash()
  end

  return true
end

function miner.branch(length)
  local startDir = state.dir

  for i = 1, length do
    if not miner.mineStep(i) then
      break
    end
  end

  movement.face((startDir + 2) % 4)

  for _ = 1, length do
    movement.forward()
  end

  movement.face(startDir)
end

function miner.run()
  term.clear()
  term.setCursorPos(1, 1)

  logger.info("Mining2000 lance.")

  if not movement.refuel() then
    return
  end

  for i = 1, config.length do
    if not miner.mineStep(i) then
      break
    end

    if i % config.branchSpacing == 0 then
      local mainDir = state.dir

      movement.turnLeft()
      miner.branch(config.branchLength)
      movement.face(mainDir)

      movement.turnRight()
      miner.branch(config.branchLength)
      movement.face(mainDir)
    end
  end

  logger.info("Minage termine.")
end

return miner