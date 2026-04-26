local base = "https://raw.githubusercontent.com/TONUSER/Mining2000/main/"

local files = {
 "startup",
 "mining2000/config",
 "mining2000/logger",
 "mining2000/state",
 "mining2000/ore",
 "mining2000/inventory",
 "mining2000/movement",
 "mining2000/miner",
 "mining2000/main"
}

for _, file in ipairs(files) do
    shell.run("delete " .. file)
    shell.run("wget " .. base .. file .. " " .. file)
    print("Installed: " .. file)
end

print("Mining2000 prêt.")