return {
  length = 200,
  branchLength = 24,
  branchSpacing = 4,

  minFuel = 500,

  torchSpacing = 8,
  torchItem = "minecraft:torch",
  placeTorches = true,

  trash = {
    ["minecraft:cobblestone"] = true,
    ["minecraft:cobbled_deepslate"] = true,
    ["minecraft:diorite"] = true,
    ["minecraft:andesite"] = true,
    ["minecraft:granite"] = true,
    ["minecraft:tuff"] = true,
    ["minecraft:gravel"] = true,
    ["minecraft:dirt"] = true,
    ["minecraft:netherrack"] = true,
    ["minecraft:end_stone"] = true,
  },

  dangerousBlocks = {
    ["minecraft:lava"] = true,
    ["minecraft:water"] = true,
  },

  protectedBlocks = {
    ["minecraft:torch"] = true,
    ["minecraft:wall_torch"] = true,
    ["minecraft:soul_torch"] = true,
    ["minecraft:soul_wall_torch"] = true,
  }
}