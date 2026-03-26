
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

-- Raycast
local raycast = hs.hotkey.modal.new({ "ctrl", "shift" }, "r")

function raycast:entered()
  hs.alert.show("raycast")
end

function raycast:exited()
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
  hs.alert.show("utils")
end

function utils:exited()
  hs.alert.closeAll()
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
    hs.alert.show("Kebab ✓")

end

utils:bind("", "k", function()
  raycast:exit()
  toKebabCase()
end)


-- exit keys
utils:bind("", "escape", function() utils:exit() end)
utils:bind("", "return", function() utils:exit() end)

-- Cleanshot X
local cleanshot_x = hs.hotkey.modal.new({ "ctrl", "shift" }, "x")

-- Area
cleanshot_x:bind("", "a", function()
  cleanshot_x:exit()
  hs.alert.show("Area ✓")
  hs.eventtap.keyStroke({"ctrl", "shift", "alt"}, "1")
end)

-- Previous Area
cleanshot_x:bind("", "p", function()
  cleanshot_x:exit()
  hs.alert.show("Previous Area ✓")
  hs.eventtap.keyStroke({"ctrl", "shift", "alt"}, "7")
end)

-- Fullscreen
cleanshot_x:bind("", "f", function()
  cleanshot_x:exit()
  hs.alert.show("Fullscreen ✓")
  hs.eventtap.keyStroke({"ctrl", "shift", "alt"}, "3")
end)

-- Window
cleanshot_x:bind("", "w", function()
  cleanshot_x:exit()
  hs.alert.show("Window ✓")
  hs.eventtap.keyStroke({"ctrl", "shift", "alt"}, "4")
end)

-- Timer
cleanshot_x:bind("", "t", function()
  cleanshot_x:exit()
  hs.alert.show("Timer ✓")
  hs.eventtap.keyStroke({"ctrl", "shift", "alt"}, "6")
end)

-- OCR
cleanshot_x:bind("", "o", function()
  cleanshot_x:exit()
  hs.alert.show("OCR ✓")
  hs.eventtap.keyStroke({"ctrl", "shift", "alt"}, "5")
end)

-- Recording
cleanshot_x:bind("", "r", function()
  cleanshot_x:exit()
  hs.alert.show("Recording ✓")
  hs.eventtap.keyStroke({"ctrl", "shift", "alt"}, "2")
end)

function cleanshot_x:entered()
  hs.alert.show("cleanshot_x")
end

function cleanshot_x:exited()
  hs.alert.closeAll()
end

-- exit keys
cleanshot_x:bind("", "escape", function() cleanshot_x:exit() end)
cleanshot_x:bind("", "return", function() cleanshot_x:exit() end)
