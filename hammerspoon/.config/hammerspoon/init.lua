-- Register Hammerspoon as a macOS login item.
if not hs.autoLaunch() then
  hs.autoLaunch(true)
end

local globalLeader = { "ctrl", "shift" }
local meh = { "ctrl", "shift", "alt" }

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello Wooooorld"}):send()
end)

hs.hotkey.bind({"cmd", "shift", "ctrl", "alt"}, "l", function()
    hs.caffeinate.systemSleep()
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

require("modes.modes").setup({
  globalLeader = globalLeader,
  meh = meh,
  isWorkMacBook = isWorkMacBook,
})
