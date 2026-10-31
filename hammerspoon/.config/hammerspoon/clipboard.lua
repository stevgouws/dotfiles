--- Pastes the clipboard as plain text, or pastes whatever was copied before the current clipboard.
local M = {}

-- How long to wait after pasting before putting the original clipboard back. The app reads the
-- clipboard a moment after the paste keystroke, so restoring too early pastes the old contents.
local RESTORE_DELAY_SECONDS = 0.2

-- Each entry is the whole clipboard (text, formatting, images, files), as read by readAllData.
-- History only covers what was copied since Hammerspoon last loaded. Reloading the config, which
-- happens on every save, clears the previous entry.
local currentEntry = hs.pasteboard.readAllData()
local currentText = hs.pasteboard.getContents()
local previousEntry = nil

local watcher = hs.pasteboard.watcher.new(function(text)
  -- Copying the same text again shouldn't push the real previous entry out of history.
  if text ~= nil and text == currentText then return end
  previousEntry, currentEntry = currentEntry, hs.pasteboard.readAllData()
  currentText = text
end)

-- Hammerspoon can garbage-collect a timer that nothing references before it fires.
local pendingRestore

--- Puts something on the clipboard with `setClipboard`, pastes it, then puts back whatever was on
--- the clipboard before. The watcher is paused so this doesn't count as a new copy.
local function pasteThenRestore(setClipboard)
  watcher:stop()
  local original = hs.pasteboard.readAllData()
  setClipboard()
  -- Sent straight to the app, because a system-wide keystroke picks up the keys still held for the
  -- hotkey: Hyper+V would arrive as Cmd+Ctrl+Alt+Shift+V instead of Cmd+V.
  hs.eventtap.keyStroke({ "cmd" }, "v", nil, hs.application.frontmostApplication())
  pendingRestore = hs.timer.doAfter(RESTORE_DELAY_SECONDS, function()
    hs.pasteboard.writeAllData(original)
    watcher:start()
  end)
end

function M.pasteUnstyled()
  local text = hs.pasteboard.getContents()
  if not text then return end
  pasteThenRestore(function() hs.pasteboard.setContents(text) end)
end

function M.pastePrevious()
  if not previousEntry then return end
  pasteThenRestore(function() hs.pasteboard.writeAllData(previousEntry) end)
end

return M
