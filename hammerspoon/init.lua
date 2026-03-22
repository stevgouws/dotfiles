
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

raycast:bind("", "k", function()
  raycast:exit()
  toKebabCase()
end)

-- Replace these with your real Raycast hotkeys
-- raycast:bind("", "f", triggerRaycast({ "ctrl", "shift", "option", "cmd" }, "-")) -- File Search
raycast:bind("", "f", function()
  raycast:exit()
  hs.urlevent.openURL("raycast://extensions/raycast/file-search/search-files")
end)
raycast:bind("", "b", function()
  raycast:exit()
  hs.urlevent.openURL("raycast://extensions/raycast/browser-bookmarks/index")
end)
 -- raycast:bind("", "c", function()
   -- raycast:exit()
   -- hs.urlevent.openURL("raycast://extensions/erics118/change-case/change-case")
 -- end)
raycast:bind("", "t", function()
  raycast:exit()
  hs.urlevent.openURL("raycast://extensions/Codely/google-chrome/search-tab")
end)

-- exit keys
raycast:bind("", "escape", function() raycast:exit() end)
raycast:bind("", "return", function() raycast:exit() end)
