local alacritty = require("alacritty")
local clipboard = require("clipboard")

local M = {}

local HYPER = { "cmd", "alt", "ctrl", "shift" }
local HOME = os.getenv("HOME")

--- Returns a hotkey action that switches to an app, launching it if needed.
--- Find an app's bundle ID with: osascript -e 'id of app "Slack"'
local function focusApp(bundleID)
  return function() hs.application.launchOrFocusByBundleID(bundleID) end
end

local bindings = {
  -- Apps
  r = function() alacritty.focusInstance(1) end,
  u = function() alacritty.focusInstance(2) end,
  space = focusApp("com.google.Chrome"),
  ["\\"] = focusApp("com.readdle.SparkDesktop"),
  ["return"] = focusApp("com.microsoft.VSCode"),
  a = focusApp("net.ankiweb.anki"),
  b = focusApp("com.bitwarden.desktop"),
  c = focusApp("com.apple.iCal"),
  e = focusApp("md.obsidian"),
  i = focusApp("com.anthropic.claudefordesktop"),
  p = focusApp("com.postmanlabs.mac"),
  q = focusApp("com.tinyapp.TablePlus"),
  t = focusApp("com.todoist.mac.Todoist"),

  -- Other
  f = function() hs.open(HOME .. "/Downloads") end,
  l = function() hs.caffeinate.systemSleep() end,
  v = clipboard.pasteUnstyled,
  tab = clipboard.pastePrevious,
}

local workMacBookBindings = {
  d = focusApp("com.electron.dockerdesktop"),
  m = focusApp("com.microsoft.teams2"),
  s = focusApp("com.tinyspeck.slackmacgap"),
}

local personalMacBookBindings = {
  w = focusApp("net.whatsapp.WhatsApp"),
  y = focusApp("com.brave.Browser"),
}

local function bindAll(keyActions)
  for key, action in pairs(keyActions) do
    hs.hotkey.bind(HYPER, key, action)
  end
end

function M.setup(opts)
  bindAll(bindings)
  bindAll(opts.isWorkMacBook and workMacBookBindings or personalMacBookBindings)
end

return M
