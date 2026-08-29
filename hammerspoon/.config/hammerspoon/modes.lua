local M = {}

function M.setup(opts)
  opts = opts or {}
  local globalLeader = opts.globalLeader
  local isWorkMacBook = opts.isWorkMacBook

  -- Modes
  local modeStatus = hs.menubar.new(true, "mode-status")

  local function bindModeStatus(modal, name)
    function modal:entered()
      modeStatus:setTitle(name)
    end

    function modal:exited()
      hs.alert.closeAll()
      modeStatus:setTitle(nil)
    end
  end

  local function bindExitKeys(modal)
    modal:bind("", "escape", function() modal:exit() end)
    modal:bind("", "return", function() modal:exit() end)
  end

  local isToShowing = false

  local function onlyCtrlAlt(flags)
    return flags.ctrl
       and flags.alt
       and not flags.cmd
       and not flags.shift
       and not flags.fn
  end

  local function showMode()
    if not isToShowing then
      modeStatus:setTitle("⌃⌥")
      isToShowing = true
    end
  end

  local function hideMode()
    if isToShowing then
      modeStatus:setTitle("")
      isToShowing = false
    end
  end

  hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(e)
    local flags = e:getFlags()

    if onlyCtrlAlt(flags) then
      showMode()
    else
      hideMode()
    end

    return false
  end):start()

  hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
    local flags = e:getFlags()

    -- Hide when another key is pressed while ctrl+alt are down
    if flags.ctrl and flags.alt then
      hideMode()
    end

    return false
  end):start()

  local function setModeStatusBriefly(status)
    modeStatus:setTitle(status)
    hs.timer.doAfter(1, function()
      modeStatus:setTitle(nil)
    end)
  end

  -- Traffic Light Status

  local trafficLightStatuses = {
    RED    = "🔴 Do not disturb",
    ORANGE = "🟠 Only if urgent",
    GREEN  = "🟢 Ok to talk",
    BLUE   = "🔵 Ok to joke around",
  }

  local trafficLightStatus = hs.menubar.new(true, "traffic-light-status")
  trafficLightStatus:setTitle(trafficLightStatuses.ORANGE)

  local function buildTrafficLightMenu()
    local menuItems = {}
    for _, status in pairs(trafficLightStatuses) do
      table.insert(menuItems, {
        title = status,
        fn = function() trafficLightStatus:setTitle(status) end,
      })
    end
    return menuItems
  end

  trafficLightStatus:setMenu(buildTrafficLightMenu)

  local trafficLight = hs.hotkey.modal.new(globalLeader, "t")

  bindModeStatus(trafficLight, "traffic light")

  trafficLight:bind("", "r", function()
    trafficLight:exit()
    trafficLightStatus:setTitle(trafficLightStatuses.RED)
  end)

  trafficLight:bind("", "o", function()
    trafficLight:exit()
    trafficLightStatus:setTitle(trafficLightStatuses.ORANGE)
  end)

  trafficLight:bind("", "g", function()
    trafficLight:exit()
    trafficLightStatus:setTitle(trafficLightStatuses.GREEN)
  end)

  trafficLight:bind("", "b", function()
    trafficLight:exit()
    trafficLightStatus:setTitle(trafficLightStatuses.BLUE)
  end)

  bindExitKeys(trafficLight)

  -- Finder
  local finder = hs.hotkey.modal.new(globalLeader, "f")
  local homeDirectory = os.getenv("HOME")

  local function openFolder(path)
    return function()
      finder:exit()
      hs.execute("/usr/bin/open " .. string.format("%q", path))
    end
  end

  bindModeStatus(finder, "finder")

  finder:bind("", "a", openFolder(homeDirectory .. "/Library/Mobile Documents/com~apple~CloudDocs/admin-docs"))
  finder:bind("", "d", openFolder(homeDirectory .. "/Downloads"))
  finder:bind("", "h", openFolder(homeDirectory))
  finder:bind("", "i", openFolder(homeDirectory .. "/Library/Mobile Documents/com~apple~CloudDocs"))

  bindExitKeys(finder)

  -- Raycast
  local raycast = hs.hotkey.modal.new(globalLeader, "r")

  bindModeStatus(raycast, "raycast")

  local raycastUrls = {
    f = "raycast://extensions/raycast/file-search/search-files",
    b = "raycast://extensions/Codely/google-chrome/search-bookmarks",
    t = "raycast://extensions/Codely/google-chrome/search-tab",
    s = "raycast://extensions/raycast/snippets/search-snippets",
    k = "raycast://extensions/eluce2/list-keyboard-maestro-macros/list?arguments=%7B%22name%22%3A%22%22%7D",
    e = "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols",
  }

  for key, url in pairs(raycastUrls) do
    raycast:bind("", key, function()
      raycast:exit()
      hs.urlevent.openURL(url)
    end)
  end

  bindExitKeys(raycast)

  -- Utils
  local utils = hs.hotkey.modal.new(globalLeader, "u")

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

  bindExitKeys(utils)

  -- Cleanshot X
  -- https://cleanshot.com/docs-api
  local cleanshot_x = hs.hotkey.modal.new(globalLeader, "c")

  -- Area
  -- Also global for ease of left hand use
  hs.hotkey.bind(opts.meh, "1", function()
    hs.urlevent.openURL("cleanshot://capture-area")
  end)

  local cleanshotActions = {
    a = { url = "cleanshot://capture-area", label = "Area ✓" },
    c = { url = "cleanshot://open-from-clipboard", label = "Opening... ✓" },
    f = { url = "cleanshot://capture-fullscreen", label = "Fullscreen ✓" },
    h = { url = "cleanshot://open-history", label = "History ✓" },
    o = { url = "cleanshot://capture-text", label = "OCR ✓" },
    p = { url = "cleanshot://capture-previous-area", label = "Previous Area ✓" },
    r = { url = "cleanshot://record-screen", label = "Recording ✓" },
    s = { url = "cleanshot://scrolling-capture", label = "Settings ✓" },
    t = { url = "cleanshot://self-timer", label = "Timer ✓" },
    w = { url = "cleanshot://capture-window", label = "Window ✓" },
  }

  for key, action in pairs(cleanshotActions) do
    cleanshot_x:bind("", key, function()
      cleanshot_x:exit()
      hs.urlevent.openURL(action.url)
      setModeStatusBriefly(action.label)
    end)
  end

  bindModeStatus(cleanshot_x, "cleanshot")
  bindExitKeys(cleanshot_x)

  -- Bookmarks
  local bookmarks = hs.hotkey.modal.new(globalLeader, "b")

  bindModeStatus(bookmarks, "bookmarks")

  local sharedBookmarks = {
    l = { name = "List", action = function()
      hs.urlevent.openURL("raycast://extensions/Codely/google-chrome/search-bookmarks")
    end },
  }

  local personalBookmarks = {
    b = { name = "Budget Totals", url = "https://docs.google.com/spreadsheets/d/19CYCpFj9xQOh8Z1J_8DdacgO3DJc69Ox-O6ijKqr920/edit?gid=628590374#gid=628590374" },
    a = { name = "Arbor", url = "https://kensington-primary-academy.uk.arbor.sc/?/guardians/home-ui/dashboard" },
    f = { name = "FNB", url = "https://www.fnb.co.za/" },
    n = { name = "Natwest", url = "https://www.onlinebanking.natwest.com/Default.aspx" },
    s = { name = "Standard Bank", url = "https://onlinebanking.standardbank.co.za/#/landing-page" },
    t = { name = "Tax Free Childcare", url = "https://www.gov.uk/sign-in-childcare-account" },
    x = { name = "Amex", url = "https://www.americanexpress.com/en-gb/account/login" },
    q = { name = "Lucia Amazon", action = function()
      hs.execute('open -na "Google Chrome" --args --profile-directory="Profile 4" "https://www.amazon.co.uk/cpe/yourpayments/transactions"')
    end },
    z = { name = "Amazon Transactions", url = "https://www.amazon.co.uk/cpe/yourpayments/transactions" },
  }

  local workBookmarks = {
    b = { name = "Sprint/Kanban Board", url = "https://voxsmart.atlassian.net/jira/software/c/projects/SRC/boards/217?assignee=712020%3A90fe3c8f-218e-4a28-aa4b-33bf6f1a448d" },
    c = { name = "Cezanne", url = "https://w3.cezanneondemand.com/CezanneHR/-/VoxSmart/view/9ebaad0a-8ad5-4d97-b2f1-e5d179149a81?ce=3&et=4d8970cb-6164-4162-b780-4574ff852be1&n=6c5063b4-8307-4f55-b968-ddc3e36e154d" },
  }

  local machineBookmarks
  if isWorkMacBook then
    machineBookmarks = workBookmarks
  else
    machineBookmarks = personalBookmarks
  end

  -- Merge shared + machine-specific
  local bookmarkMap = hs.fnutils.copy(sharedBookmarks)
  for k, v in pairs(machineBookmarks) do
    bookmarkMap[k] = v
  end

  for key, entry in pairs(bookmarkMap) do
    bookmarks:bind("", key, function()
      bookmarks:exit()
      if entry.action then
        entry.action()
      else
        hs.urlevent.openURLWithBundle(entry.url, "com.google.Chrome")
      end
    end)
  end

  bindExitKeys(bookmarks)

  return {
    modeStatus = modeStatus,
    trafficLight = trafficLight,
    finder = finder,
    raycast = raycast,
    utils = utils,
    cleanshot_x = cleanshot_x,
    bookmarks = bookmarks,
  }
end

return M
