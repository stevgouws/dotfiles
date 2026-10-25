local M = {}

function M.setup(opts)
  local bindModeStatus = opts.bindModeStatus
  local bindExitKeys = opts.bindExitKeys
  local setModeStatusBriefly = opts.setModeStatusBriefly

  local utils = hs.hotkey.modal.new(opts.globalLeader, "u")

  utils:bind("", "b", function()
    utils:exit()
    hs.execute("open /System/Library/PreferencePanes/Bluetooth.prefPane")
  end)

  bindModeStatus(utils, "utils")

  local function toKebabCase()
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
    setModeStatusBriefly("Kebab ✓")
  end

  utils:bind("", "k", function()
    utils:exit()
    toKebabCase()
  end)

  local VSCODE = "com.microsoft.VSCode"
  local ANKI = "net.ankiweb.anki"
  local WAIT_TIMEOUT_SECONDS = 10

  -- Held here so the pending timer isn't garbage collected mid-wait.
  local waitTimer = nil

  --- Runs `fn` once `predicate` is true, or gives up silently after the timeout.
  local function waitUntil(predicate, fn)
    local deadline = hs.timer.secondsSinceEpoch() + WAIT_TIMEOUT_SECONDS
    waitTimer = hs.timer.waitUntil(
      function() return predicate() or hs.timer.secondsSinceEpoch() > deadline end,
      function() if predicate() then fn() end end,
      0.1
    )
  end

  local function isFront(bundleID)
    local app = hs.application.frontmostApplication()
    return app ~= nil and app:bundleID() == bundleID
  end

  local function isAnkiDeckListFront()
    local window = hs.window.frontmostWindow()
    return isFront(ANKI) and window ~= nil and window:title() == "User 1 - Anki"
  end

  -- VS Code puts the folder name in the window title by default, e.g. "notes.md — practice".
  local function isPracticeWindowFront()
    local window = hs.window.frontmostWindow()
    return isFront(VSCODE) and window ~= nil and window:title():find("practice", 1, true) ~= nil
  end

  local function activateAllWindows(bundleID)
    local app = hs.application.get(bundleID)
    if app then
      app:activate(true)
    else
      hs.application.launchOrFocusByBundleID(bundleID)
    end
  end

  local function minimizeAllWindows(bundleID)
    local app = hs.application.get(bundleID)
    if not app then return end
    for _, window in ipairs(app:allWindows()) do
      window:minimize()
    end
  end

  --- Opens the practice project on the left half of the screen and Anki on the right half.
  local function startPractice()
    -- Start both apps opening up front so their load times overlap.
    activateAllWindows(ANKI)
    minimizeAllWindows(VSCODE)
    hs.execute("/opt/homebrew/bin/code " .. os.getenv("HOME") .. "/projects/practice")

    activateAllWindows(ANKI)
    waitUntil(isAnkiDeckListFront, function()
      hs.window.frontmostWindow():moveToUnit(hs.layout.right50)
      hs.eventtap.keyStroke({}, "d")
      activateAllWindows(VSCODE)
      waitUntil(isPracticeWindowFront, function()
        hs.window.frontmostWindow():moveToUnit(hs.layout.left50)
        activateAllWindows(ANKI)
      end)
    end)
  end

  utils:bind("", "p", function()
    utils:exit()
    startPractice()
  end)

  bindExitKeys(utils)

  return utils
end

return M
