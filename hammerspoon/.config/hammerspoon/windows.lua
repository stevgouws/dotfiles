--- Resizes the focused window and moves it between displays.
local M = {}

-- Hammerspoon animates by resizing the window over and over, and each resize makes the app redraw,
-- so any animation looks choppy.
hs.window.animationDuration = 0

--- Returns a hotkey action that runs `fn` with the focused window, if there is one.
local function withFocusedWindow(fn)
  return function()
    local win = hs.window.focusedWindow()
    if win then fn(win) end
  end
end

local leftHalf = withFocusedWindow(function(win) win:moveToUnit(hs.layout.left50) end)
local rightHalf = withFocusedWindow(function(win) win:moveToUnit(hs.layout.right50) end)
local maximize = withFocusedWindow(function(win) win:maximize() end)

--- Moves the window to `screen`, scaling it to match. Windows moved to the main screen are always
--- maximised: Hammerspoon's move alone leaves a full-size laptop window at roughly 75% there.
--- https://github.com/Hammerspoon/hammerspoon/issues/3739
local function moveToDisplay(win, screen)
  win:moveToScreen(screen)
  if screen:id() == hs.screen.primaryScreen():id() then win:maximize() end
end

local nextDisplay = withFocusedWindow(function(win) moveToDisplay(win, win:screen():next()) end)
local previousDisplay = withFocusedWindow(function(win) moveToDisplay(win, win:screen():previous()) end)

function M.setup(opts)
  hs.hotkey.bind({ "ctrl" }, "left", leftHalf)
  hs.hotkey.bind({ "ctrl" }, "right", rightHalf)
  hs.hotkey.bind({ "ctrl" }, "up", maximize)

  -- The display keys follow where the laptop sits: left of the main screen at work, below it at home.
  if opts.isWorkMacBook then
    hs.hotkey.bind({ "ctrl", "shift" }, "left", previousDisplay)
    hs.hotkey.bind({ "ctrl", "shift" }, "right", nextDisplay)
  else
    hs.hotkey.bind({ "ctrl", "shift" }, "up", previousDisplay)
    hs.hotkey.bind({ "ctrl", "shift" }, "down", nextDisplay)
  end
end

return M
