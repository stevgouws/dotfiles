
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
hs.alert.show("Config loaded...")

-- Modes

-- Raycast
local raycast = hs.hotkey.modal.new({ "ctrl", "shift" }, "r")

function raycast:entered()
  hs.alert.show("Raycast")
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

-- exit keys
raycast:bind("", "escape", function() raycast:exit() end)
raycast:bind("", "return", function() raycast:exit() end)

-- Utils
local utils = hs.hotkey.modal.new({ "ctrl", "shift" }, "u")

function utils:entered()
  hs.alert.show("Utils")
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
