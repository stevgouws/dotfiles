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
hs.alert.show("Config loaded...")

-- Modes
modeStatus = hs.menubar.new(true, "mode-status")
-- modeStatus:setTitle(nil)

local isToShowing = false

local function onlyCtrlShift(flags)
    return flags.ctrl
       and flags.shift
       and not flags.cmd
       and not flags.alt
       and not flags.fn
end

local function showMode()
    if not isToShowing then
        modeStatus:setTitle("⌃⇧")
        isToShowing = true
    end
end

local function hideMode()
    if isToShowing then
        modeStatus:setTitle("")
        isToShowing = false
    end
end

hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(e)
    local flags = e:getFlags()

    if onlyCtrlShift(flags) then
        showMode()
    else
        hideMode()
    end

    return false
end):start()

hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
    local flags = e:getFlags()

    -- Hide when another key is pressed while ctrl+shift are down
    if flags.ctrl and flags.shift then
        hideMode()
    end

    return false
end):start()

local function setModeStatusBriefly(status)
  modeStatus:setTitle(status)
  hs.timer.doAfter(1, function()
    modeStatus:setTitle(nil)
  end)
end

-- Raycast
local raycast = hs.hotkey.modal.new({ "ctrl", "shift" }, "r")

function raycast:entered()
  modeStatus:setTitle("raycast")
end

function raycast:exited()
  modeStatus:setTitle(nil)
  hs.alert.closeAll()
end

local function triggerRaycast(mods, key)
  return function()
    raycast:exit()
    hs.eventtap.keyStroke(mods, key, 0)
  end
end



-- raycast:bind("", "f", triggerRaycast({ "ctrl", "shift", "option", "cmd" }, "-")) -- File Search
raycast:bind("", "f", function()
  raycast:exit()
  hs.urlevent.openURL("raycast://extensions/raycast/file-search/search-files")
end)

raycast:bind("", "b", function()
  raycast:exit()
  hs.urlevent.openURL("raycast://extensions/raycast/browser-bookmarks/index")
end)

raycast:bind("", "t", function()
  raycast:exit()
  hs.urlevent.openURL("raycast://extensions/Codely/google-chrome/search-tab")
end)

raycast:bind("", "s", function()
  raycast:exit()
  hs.urlevent.openURL("raycast://extensions/raycast/snippets/search-snippets")
end)

raycast:bind("", "k", function()
  raycast:exit()
  hs.urlevent.openURL("raycast://extensions/eluce2/list-keyboard-maestro-macros/list?arguments=%7B%22name%22%3A%22%22%7D")
end)

raycast:bind("", "e", function()
  raycast:exit()
  hs.urlevent.openURL("raycast://extensions/raycast/emoji-symbols/search-emoji-symbols")
end)

-- exit keys
raycast:bind("", "escape", function() raycast:exit() end)
raycast:bind("", "return", function() raycast:exit() end)

-- Utils
local utils = hs.hotkey.modal.new({ "ctrl", "shift" }, "u")

utils:bind("", "b", function()
  utils:exit()
  hs.execute("open /System/Library/PreferencePanes/Bluetooth.prefPane")
end)

function utils:entered()
  modeStatus:setTitle("utils")
end

function utils:exited()
  hs.alert.closeAll()
  modeStatus:setTitle(nil)
end

function toKebabCase()
  local text = hs.pasteboard.getContents()
  if not text then return end

  -- convert to kebab-case
  local kebab = text
    :gsub("([a-z0-9])([A-Z])", "%1-%2") -- camelCase → camel-Case
    :gsub("[%s_]+", "-")               -- spaces/underscores → -
    :gsub("[^%w%-]", "")               -- remove non-word chars
    :gsub("%-+", "-")                  -- collapse multiple -
    :gsub("^%-", "")                   -- trim leading -
    :gsub("%-$", "")                   -- trim trailing -
    :lower()

    hs.pasteboard.setContents(kebab)
    hs.eventtap.keyStroke({ "cmd" }, "v")
    setModeStatusBriefly("Kebab ✓")
end

utils:bind("", "k", function()
  utils:exit()
  toKebabCase()
end)


-- exit keys
utils:bind("", "escape", function() utils:exit() end)
utils:bind("", "return", function() utils:exit() end)

-- Cleanshot X
local cleanshot_x = hs.hotkey.modal.new({ "ctrl", "shift" }, "c")

-- Area
cleanshot_x:bind("", "a", function()
  cleanshot_x:exit()
  hs.eventtap.keyStroke({"ctrl", "shift", "alt"}, "1")
  setModeStatusBriefly("Area ✓")
end)

-- Previous Area
cleanshot_x:bind("", "p", function()
  cleanshot_x:exit()
  hs.eventtap.keyStroke({"ctrl", "shift", "alt"}, "7")
  setModeStatusBriefly("Previous Area ✓")
end)

-- Fullscreen
cleanshot_x:bind("", "f", function()
  cleanshot_x:exit()
  hs.eventtap.keyStroke({"ctrl", "shift", "alt"}, "3")
  setModeStatusBriefly("Fullscreen ✓")
end)

-- Window
cleanshot_x:bind("", "w", function()
  cleanshot_x:exit()
  hs.eventtap.keyStroke({"ctrl", "shift", "alt"}, "4")
  setModeStatusBriefly("Window ✓")
end)

-- Timer
cleanshot_x:bind("", "t", function()
  cleanshot_x:exit()
  hs.eventtap.keyStroke({"ctrl", "shift", "alt"}, "6")
  setModeStatusBriefly("Timer ✓")
end)

-- OCR
cleanshot_x:bind("", "o", function()
  cleanshot_x:exit()
  hs.eventtap.keyStroke({"ctrl", "shift", "alt"}, "5")
  setModeStatusBriefly("OCR ✓")
end)

-- Recording
cleanshot_x:bind("", "r", function()
  cleanshot_x:exit()
  hs.eventtap.keyStroke({"ctrl", "shift", "alt"}, "2")
  setModeStatusBriefly("Recording ✓")
end)

function cleanshot_x:entered()
  modeStatus:setTitle("cleanshot")
end

function cleanshot_x:exited()
  hs.alert.closeAll()
  modeStatus:setTitle(nil)
end

-- exit keys
cleanshot_x:bind("", "escape", function() cleanshot_x:exit() end)
cleanshot_x:bind("", "return", function() cleanshot_x:exit() end)

-- Bookmarks
local bookmarks = hs.hotkey.modal.new({ "ctrl", "shift" }, "b")

function bookmarks:entered()
  modeStatus:setTitle("bookmarks")
end

function bookmarks:exited()
  hs.alert.closeAll()
  modeStatus:setTitle(nil)
end

-- Identify machine
local machineName = hs.host.localizedName()
-- (Optional) print to console once to confirm names
print(machineName)

local sharedBookmarks = {
}

local personalBookmarks = {
  b = { name = "Budget Totals", url = "https://docs.google.com/spreadsheets/d/19CYCpFj9xQOh8Z1J_8DdacgO3DJc69Ox-O6ijKqr920/edit?gid=628590374#gid=628590374" },
  a = { name = "Amazon Transactions", url = "https://www.amazon.co.uk/cpe/yourpayments/transactions" },
  t = { name = "Tax Free Childcare", url = "https://www.gov.uk/sign-in-childcare-account" },
  s = { name = "Standard Bank", url = "https://onlinebanking.standardbank.co.za/#/landing-page" },
  f = { name = "FNB", url = "https://www.fnb.co.za/" },
}

local workBookmarks = {
  b = { name = "Sprint/Kanban Board", url = "https://voxsmart.atlassian.net/jira/software/c/projects/SRC/boards/217" },
}

local machineBookmarks = {}

if machineName == "MacBook Pro" then
  machineBookmarks = personalBookmarks
elseif machineName == "Steven’s MacBook Pro" then
  machineBookmarks = workBookmarks
end

-- Merge shared + machine-specific
local bookmarkMap = hs.fnutils.copy(sharedBookmarks)
for k, v in pairs(machineBookmarks) do
  bookmarkMap[k] = v
end

for key, entry in pairs(bookmarkMap) do
  bookmarks:bind("", key, function()
    bookmarks:exit()
    hs.urlevent.openURLWithBundle(entry.url, "com.google.Chrome")
  end)
end

-- exit keys
bookmarks:bind("", "escape", function() bookmarks:exit() end)
bookmarks:bind("", "return", function() bookmarks:exit() end)
