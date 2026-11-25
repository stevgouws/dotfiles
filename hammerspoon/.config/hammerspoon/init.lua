-- Lets the `hs` command-line tool talk to Hammerspoon, e.g. `hs -c 'hs.reload()'`.
require("hs.ipc")

-- Register Hammerspoon as a macOS login item.
if not hs.autoLaunch() then
  hs.autoLaunch(true)
end

local globalLeader = { "ctrl", "shift" }
local meh = { "ctrl", "shift", "alt" }

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello Wooooorld"}):send()
end)

-- auto reload config when changed
function reloadConfig(files)
  doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.config/hammerspoon/", reloadConfig):start()

local _, workMacBookStatus = hs.execute("is-work-macbook", true)
local isWorkMacBook = workMacBookStatus == true
print("-----------> isWorkMacBook: " .. tostring(isWorkMacBook))

hs.alert.show("Config loaded...")

require("hyper").setup({ isWorkMacBook = isWorkMacBook })
require("windows").setup({ isWorkMacBook = isWorkMacBook })
require("anki").setup({ meh = meh })
require("tmux_vscode").setup({ meh = meh })

if isWorkMacBook then
  local vault = os.getenv("HOME") .. "/obsidian-sync/VoxSmart"
  local historyFile = "tickets/UUI-2582 - Epic daily shortfall.csv"
  local epicHistory = require("widgets.epic_history")
  require("widgets.epic").setup({
    vault = vault,
    title = "VSP new UI · Communications",
    epicNote = "tickets/UUI-2582 - Epic - New VSP UI - Communications Page.md",
    tag = "new-vsp-ui",
    assignee = "Steven",
    style = "wasp",
    historyFile = historyFile,
    spaceBelow = epicHistory.height,
  })
  epicHistory.setup({
    historyFile = vault .. "/" .. historyFile,
    title = "Days ahead or short, end of day",
    style = "wasp",
  })
end

require("modes.modes").setup({
  globalLeader = globalLeader,
  meh = meh,
  isWorkMacBook = isWorkMacBook,
})
