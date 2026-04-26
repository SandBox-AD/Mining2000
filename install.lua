local base = "https://raw.githubusercontent.com/SandBox-AD/Mining2000/main/"

local files = {
  { url = "startup.lua", dest = "startup" },

  { url = "mining2000/config.lua", dest = "mining2000/config" },
  { url = "mining2000/logger.lua", dest = "mining2000/logger" },
  { url = "mining2000/state.lua", dest = "mining2000/state" },
  { url = "mining2000/ore.lua", dest = "mining2000/ore" },
  { url = "mining2000/inventory.lua", dest = "mining2000/inventory" },
  { url = "mining2000/movement.lua", dest = "mining2000/movement" },
  { url = "mining2000/miner.lua", dest = "mining2000/miner" },
  { url = "mining2000/main.lua", dest = "mining2000/main" },
}

local function download(urlPath, dest)
  local url = base .. urlPath

  if fs.exists(dest) then
    fs.delete(dest)
  end

  shell.run("wget " .. url .. " " .. dest)
end

print("Installing Mining2000...")

for _, file in ipairs(files) do
  local dir = fs.getDir(file.dest)

  if dir ~= "" and not fs.exists(dir) then
    fs.makeDir(dir)
  end

  download(file.url, file.dest)
  print("Installed: " .. file.dest)
end

pcall(function()
  os.setComputerLabel("Mining2000")
end)

print("Mining2000 pret.")
print("Lance avec: startup")