--- Anki-only shortcuts. They are switched on while Anki is the frontmost app and off otherwise,
--- so the same keys keep working normally everywhere else.
local M = {}

local ANKI_BUNDLE_ID = "net.ankiweb.anki"

local VSCODE_BUNDLE_ID = "com.microsoft.VSCode"

-- How long each simulated key is held down. Hammerspoon's default is 200ms, and it blocks while
-- holding, so a shortcut that sends three keys would take over half a second.
local KEY_HOLD_MICROSECONDS = 20000

local function isApp(app, bundleID)
  return app ~= nil and app:bundleID() == bundleID
end

--- Sends a keystroke straight to an app (Anki by default), because a system-wide keystroke picks up
--- the keys still held for the hotkey: Meh+C would send Cmd+A as Cmd+Ctrl+Alt+Shift+A.
local function press(mods, key, app)
  hs.eventtap.keyStroke(mods, key, KEY_HOLD_MICROSECONDS, app or hs.application.frontmostApplication())
end

--- Sends a keystroke system-wide, for apps that ignore keystrokes sent straight to them (e.g. VS
--- Code). Only safe once the hotkey's modifiers have been released.
local function pressGlobal(mods, key)
  hs.eventtap.keyStroke(mods, key, KEY_HOLD_MICROSECONDS)
end

local function modifiersHeld()
  local mods = hs.eventtap.checkKeyboardModifiers()
  return mods.cmd or mods.alt or mods.shift or mods.ctrl or mods.fn
end

-- Hammerspoon can garbage-collect a timer that nothing references before it fires.
local pendingSwitch

--- Brings the app forward, then runs `fn` once it is frontmost and the hotkey's modifiers have been
--- released, so keystrokes sent system-wide from `fn` land in it unchanged. Gives up after a couple
--- of seconds, so a slow launch doesn't paste into VS Code long after the shortcut was pressed.
local function whenFrontmostAndReleased(bundleID, fn)
  hs.application.launchOrFocusByBundleID(bundleID)
  local deadline = hs.timer.secondsSinceEpoch() + 2
  local function ready()
    return isApp(hs.application.frontmostApplication(), bundleID) and not modifiersHeld()
  end
  pendingSwitch = hs.timer.waitUntil(function()
    return ready() or hs.timer.secondsSinceEpoch() > deadline
  end, function()
    if ready() then fn() end
  end, 0.02)
end

--- Focuses the most recently used window that isn't Anki's. Cmd+Tab can't be used for this: it is
--- handled by macOS itself, so it can't be sent to an app, and sent system-wide it would pick up the
--- held hotkey modifiers.
local function focusPreviousApp()
  for _, win in ipairs(hs.window.orderedWindows()) do
    if not isApp(win:application(), ANKI_BUNDLE_ID) then return win:focus() end
  end
end

--- Copies the whole field, then moves the cursor to the end so the field isn't left highlighted.
local function copyField()
  press({ "cmd" }, "a")
  press({ "cmd" }, "c")
  press({}, "right")
end

local function copyFieldAndGoBack()
  copyField()
  focusPreviousApp()
end

local function copyFieldToVSCode()
  copyField()
  whenFrontmostAndReleased(VSCODE_BUNDLE_ID, function()
    pressGlobal({ "cmd" }, "a")
    pressGlobal({ "cmd" }, "v")
    pressGlobal({}, "escape")
  end)
end

--- Cmd+Shift+H opens Anki's add-link prompt in the editor; the clipboard becomes the link target.
local function pasteMarkdownLink()
  press({ "cmd", "shift" }, "h")
  press({ "cmd" }, "v")
  press({}, "return")
end

--- Pressing D in the main window (decks screen) also syncs. D still reaches Anki untouched, with Y,
--- the sync key, posted right after it. Only the main window has "Anki" in its title, so typing a
--- "d" in the Add or Browse window doesn't sync.
local syncOnDecks = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
  if event:getKeyCode() ~= hs.keycodes.map.d then return false end
  if next(event:getFlags()) ~= nil or event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat) == 1 then
    return false
  end
  local win = hs.window.focusedWindow()
  if not (win and win:title():find("Anki", 1, true)) then return false end
  return false, {
    hs.eventtap.event.newKeyEvent({}, "y", true),
    hs.eventtap.event.newKeyEvent({}, "y", false),
  }
end)

local hotkeys = {}

local function setEnabled(enabled)
  for _, hotkey in ipairs(hotkeys) do
    if enabled then hotkey:enable() else hotkey:disable() end
  end
  if enabled then syncOnDecks:start() else syncOnDecks:stop() end
end

-- Hammerspoon can garbage-collect a watcher that nothing references, which silently stops it.
local appWatcher

function M.setup(opts)
  local meh = opts.meh
  hotkeys = {
    hs.hotkey.new({ "cmd" }, "k", pasteMarkdownLink),
    hs.hotkey.new(meh, "c", copyFieldAndGoBack),
    hs.hotkey.new(meh, "p", copyFieldToVSCode),
    hs.hotkey.new(meh, "delete", function() press({ "cmd" }, "delete") end),
    hs.hotkey.new(meh, "e", function() press({ "cmd", "alt" }, "x") end),
  }

  appWatcher = hs.application.watcher.new(function(_, event, app)
    if event == hs.application.watcher.activated then setEnabled(isApp(app, ANKI_BUNDLE_ID)) end
  end)
  appWatcher:start()
  setEnabled(isApp(hs.application.frontmostApplication(), ANKI_BUNDLE_ID))
end

return M
