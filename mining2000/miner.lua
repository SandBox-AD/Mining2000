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

  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)

    if item and item.name == config.torchItem then
      turtle.select(slot)

      local startDir = state.dir
      movement.turnRight()

      local placed = turtle.place()

      movement.face(startDir)
      turtle.select(1)

      if placed then
        logger.info("Torche posee.")
      end

      return placed
    end
  end

  logger.warn("Plus de torches, on continue.")
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
    logger.info("Minerai devant: " .. blockFront.name)
    turtle.dig()

    if movement.forward() then
      mineConnectedOre(depth + 1)
      back()
    end
  end

  local okUp, blockUp = turtle.inspectUp()
  if okUp and ore.isOre(blockUp.name) then
    logger.info("Minerai haut: " .. blockUp.name)
    turtle.digUp()

    if movement.up() then
      mineConnectedOre(depth + 1)
      movement.down()
    end
  end

  local okDown, blockDown = turtle.inspectDown()
  if okDown and ore.isOre(blockDown.name) then
    logger.info("Minerai bas: " .. blockDown.name)
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
    logger.info("Minerai gauche: " .. blockLeft.name)
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
    logger.info("Minerai droite: " .. blockRight.name)
    turtle.dig()

    if movement.forward() then
      mineConnectedOre(depth + 1)
      back()
    end
  end
  movement.face(startDir)
end

local function checkFrontCeilingOre()
  local startDir = state.dir

  if not movement.forward() then
    return
  end

  local okUp, blockUp = turtle.inspectUp()
  if okUp and ore.isOre(blockUp.name) then
    logger.info("Minerai plafond devant: " .. blockUp.name)
    turtle.digUp()

    if movement.up() then
      mineConnectedOre(1)
      movement.down()
    end
  end

  movement.face((startDir + 2) % 4)
  movement.forward()
  movement.face(startDir)
end

function miner.mineStep(stepIndex)
  movement.safeDigUp()

  checkFrontCeilingOre()

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
    logger.info("Branche: " .. i .. "/" .. length)

    if not miner.mineStep(i) then
      logger.warn("Branche interrompue.")
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
  logger.info("Tunnel: " .. config.length)
  logger.info("Branche: " .. config.branchLength)
  logger.info("Espacement: " .. config.branchSpacing)

  if not movement.refuel() then
    return
  end

  for i = 1, config.length do
    logger.info("Tunnel principal: " .. i .. "/" .. config.length)

    if not miner.mineStep(i) then
      logger.warn("Tunnel interrompu.")
      break
    end

    if i % config.branchSpacing == 0 then
      local mainDir = state.dir

      logger.info("Branche gauche.")
      movement.turnLeft()
      miner.branch(config.branchLength)
      movement.face(mainDir)

      logger.info("Branche droite.")
      movement.turnRight()
      miner.branch(config.branchLength)
      movement.face(mainDir)
    end
  end

  logger.info("Minage termine.")
end

return miner