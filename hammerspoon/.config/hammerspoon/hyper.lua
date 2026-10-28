local alacritty = require("alacritty")

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

  -- Other
  f = function() hs.open(HOME .. "/Downloads") end,
  l = function() hs.caffeinate.systemSleep() end,
}

function M.setup()
  for key, action in pairs(bindings) do
    hs.hotkey.bind(HYPER, key, action)
  end
end

return M
