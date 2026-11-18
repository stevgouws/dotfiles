--- Windows mode: focuses the nearest window in a direction, like Ctrl+w h/j/k/l in Vim.
--- While the mode is active the focused window is outlined, and the window focus moves to
--- is outlined briefly so it's easy to spot.
local M = {}

local OUTLINE_WIDTH = 4
local OUTLINE_FLASH_SECONDS = 0.25

local focusDirections = {
  h = "windowsToWest",
  j = "windowsToSouth",
  k = "windowsToNorth",
  l = "windowsToEast",
}

-- Lua only sees local functions declared above the code that uses them, so the outline
-- helpers sit above setup.
local outline = nil
local outlineTimer = nil

local function hideOutline()
  if outlineTimer then
    outlineTimer:stop()
    outlineTimer = nil
  end
  if outline then
    outline:delete()
    outline = nil
  end
end

--- Draws a border around `win`. With `duration` (seconds) it hides itself afterwards,
--- otherwise it stays until hideOutline is called.
local function showOutline(win, color, duration)
  hideOutline()
  local frame = win:frame()
  outline = hs.canvas.new(frame)
  outline:appendElements({
    type = "rectangle",
    action = "stroke",
    strokeColor = color,
    strokeWidth = OUTLINE_WIDTH,
    roundedRectRadii = { xRadius = 10, yRadius = 10 },
    -- The stroke is centred on the rectangle's edge, so inset by half its width to keep
    -- all of it inside the canvas.
    frame = {
      x = OUTLINE_WIDTH / 2,
      y = OUTLINE_WIDTH / 2,
      w = frame.w - OUTLINE_WIDTH,
      h = frame.h - OUTLINE_WIDTH,
    },
  })
  outline:level(hs.canvas.windowLevels.overlay)
  outline:clickActivating(false)
  outline:show()
  if duration then
    outlineTimer = hs.timer.doAfter(duration, hideOutline)
  end
end

function M.setup(opts)
  local color = opts.outlineColor
  local windows = hs.hotkey.modal.new(opts.globalLeader, "w")

  opts.bindModeStatus(windows, "windows")

  local showModeStatus = windows.entered
  local hideModeStatus = windows.exited

  function windows:entered()
    showModeStatus(self)
    local win = hs.window.focusedWindow()
    if win then showOutline(win, color) end
  end

  function windows:exited()
    hideModeStatus(self)
    hideOutline()
  end

  for key, method in pairs(focusDirections) do
    windows:bind("", key, function()
      windows:exit()
      local win = hs.window.focusedWindow()
      if not win then return end
      -- Passing true for frontmost skips windows that are covered by other windows.
      -- The list is sorted nearest first.
      local target = win[method](win, nil, true)[1]
      if target then
        target:focus()
        showOutline(target, color, OUTLINE_FLASH_SECONDS)
      end
    end)
  end

  opts.bindExitKeys(windows)

  return windows
end

return M
