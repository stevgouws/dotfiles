--- Anki-only shortcuts. They are switched on while Anki is the frontmost app and off otherwise,
--- so the same keys keep working normally everywhere else.
local M = {}

local ANKI_BUNDLE_ID = "net.ankiweb.anki"

local VSCODE_BUNDLE_ID = "com.microsoft.VSCode"
local TABLEPLUS_BUNDLE_ID = "com.tinyapp.TablePlus"

-- How long each simulated key is held down. Hammerspoon's default is 200ms, and it blocks while
-- holding, so a shortcut that sends three keys would take over half a second.
local KEY_HOLD_MICROSECONDS = 20000

--- A pinned tab, by position (1 = leftmost), in the VS Code window for the "practice" project. The
--- window is found by its title, which starts with the project folder's name (VS Code's
--- window.title setting puts ${rootName} first).
local function practiceTab(position)
  return { app = VSCODE_BUNDLE_ID, windowTitle = "^practice ", tab = position }
end

-- Where Meh+P pastes: an app, and a Lua pattern its window's title must match. A note tagged
-- target::<name>, e.g. target::js, always goes there, ahead of the note type and deck below.
local TARGETS = {
  js = practiceTab(1),
  vitest = practiceTab(2),
  untitled = practiceTab(3),
  tsx = practiceTab(4),
  bash = practiceTab(5),
  html = practiceTab(6),
  -- TablePlus titles its windows "<connection name> : <database> - <engine>", e.g. "Practice :
  -- sql-practice.db - SQLite 3.53.1". Matched on the database file, since the connection's name can
  -- differ between Macs. In Lua patterns "-" and "." are special, so they're escaped with "%".
  sql = { app = TABLEPLUS_BUNDLE_ID, windowTitle = " : sql%-practice%.db " },
}

--- "Make the tests pass" cards go to the Vitest tab whatever their deck.
local TARGET_BY_NOTE_TYPE = {
  ["Make the tests pass"] = TARGETS.vitest,
}

--- Other cards go by deck. A subdeck uses its parent's target unless it has its own entry, e.g.
--- Main::Javascript::Jest goes to js. Decks with no entry go to untitled.
local TARGET_BY_DECK = {
  ["Main::Javascript"] = TARGETS.js,
  ["Main::Javascript::Typescript"] = TARGETS.tsx,
  ["Main::Javascript::React"] = TARGETS.tsx,
  ["Main::Bash"] = TARGETS.bash,
  ["Main::HTML"] = TARGETS.html,
  ["Main::SQL"] = TARGETS.sql,
  ["Main::SQL::Drizzle"] = TARGETS.untitled,
}

local ANKI_CONNECT_URL = "http://localhost:8765"

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

--- Focuses the window, then runs `fn` once it has focus and the hotkey's modifiers have been
--- released, so keystrokes sent system-wide from `fn` land in it unchanged. Gives up after a couple
--- of seconds, so a slow switch doesn't paste long after the shortcut was pressed.
local function whenFocusedAndReleased(win, fn)
  win:focus()
  local deadline = hs.timer.secondsSinceEpoch() + 2
  local function ready()
    local focused = hs.window.focusedWindow()
    return focused ~= nil and focused:id() == win:id() and not modifiersHeld()
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

local cachedAnkiConnectKey

--- AnkiConnect's API key, read from the macOS Keychain the first time it's needed.
local function ankiConnectKey()
  if not cachedAnkiConnectKey then
    local output, ok = hs.execute("security find-generic-password -s anki-connect -w")
    if ok then cachedAnkiConnectKey = output:gsub("%s+$", "") end
  end
  return cachedAnkiConnectKey
end

--- Runs an AnkiConnect action and returns its result, or nil if it fails.
local function ankiConnect(action, params)
  local key = ankiConnectKey()
  if not key then return nil end
  local body = hs.json.encode({ action = action, version = 6, key = key, params = params })
  local status, response = hs.http.post(ANKI_CONNECT_URL, body, { ["Content-Type"] = "application/json" })
  if status ~= 200 then return nil end
  local decoded = hs.json.decode(response)
  return decoded and decoded.result
end

--- The card being reviewed (also the card open in Edit while reviewing), with its deckName,
--- modelName (note type) and its note's tags, or nil when there isn't one, e.g. in the Browse window.
local function currentCard()
  local card = ankiConnect("guiCurrentCard")
  if not card then return nil end
  -- guiCurrentCard doesn't include tags, so they come from the card's note.
  local notes = ankiConnect("notesInfo", { query = "cid:" .. card.cardId })
  card.tags = notes and notes[1] and notes[1].tags or {}
  return card
end

local function targetForTags(tags)
  for _, tag in ipairs(tags) do
    local name = tag:match("^target::(.+)$")
    if name and TARGETS[name] then return TARGETS[name] end
  end
end

local function targetForCard(card)
  if not card then return TARGETS.untitled end
  local taggedTarget = targetForTags(card.tags)
  if taggedTarget then return taggedTarget end
  if TARGET_BY_NOTE_TYPE[card.modelName] then return TARGET_BY_NOTE_TYPE[card.modelName] end
  local deck = card.deckName
  while deck do
    if TARGET_BY_DECK[deck] then return TARGET_BY_DECK[deck] end
    deck = deck:match("^(.*)::[^:]+$")
  end
  return TARGETS.untitled
end

--- Ctrl+1 to Ctrl+8 are VS Code's default keys for opening the tab at that position.
local function selectVSCodeTab(tab)
  pressGlobal({ "ctrl" }, tostring(tab))
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

--- The target's window, found by its title. Nil when the app or window isn't open.
local function windowForTarget(target)
  local app = hs.application.get(target.app)
  if not app then return nil end
  for _, win in ipairs(app:allWindows()) do
    if win:title():find(target.windowTitle) then return win end
  end
end

--- Replaces everything in the target (e.g. a VS Code tab, or TablePlus's query editor) with the
--- field. Does nothing when the target's window isn't open, rather than falling back to another
--- window, where select-all and paste would overwrite whatever file is open there.
local function copyFieldToTarget()
  copyField()
  local target = targetForCard(currentCard())
  local win = windowForTarget(target)
  if not win then
    hs.alert.show("Meh+P: target window isn't open")
    return
  end
  whenFocusedAndReleased(win, function()
    if target.tab then selectVSCodeTab(target.tab) end
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
    hs.hotkey.new(meh, "p", copyFieldToTarget),
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
