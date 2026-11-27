--- A desktop widget, below the epic widget, charting how many days ahead or short the epic was
--- at the end of each working day, to show whether it's catching up or falling further behind, how
--- many points are done today against a day's worth and the pace to hit the due date, and when it's
--- short, which tickets to get to Ready for Testing today to catch up. It reads the history file that
--- widgets/epic.lua writes, and redraws whenever that file or the epic widget's figures change. The
--- card itself is widgets/epic_history.html.
local M = {}

local epic = require("widgets.epic")

-- Declared up front so the helpers further down stay local to this file but can still be called from setup.
local place, render, measureCard, todaysSnapshot, resize, readHistory

local TEMPLATE = hs.configdir .. "/widgets/epic_history.html"

-- The window fits the 360px-wide card plus the page padding in epic_history.html, with little to
-- spare so the epic card sits just above it. It grows by a row for each ticket in the catch-up list,
-- up to MAX_ROWS, and anything taller is cut off, so keep these in step with the card's CSS.
local WIDTH, BASE_HEIGHT = 400, 338
local LIST_HEADER_HEIGHT, ROW_HEIGHT, MAX_ROWS = 28, 17, 9

local CARD_GAP = 12

local height = BASE_HEIGHT
local cardHeight

--- How much of the bottom of the screen this widget takes up, for the epic widget to leave free. It
--- goes by the card's real height rather than the window's, as the window has room to spare above the
--- card, so the epic card sits CARD_GAP above it. Both pages have the same bottom padding, which cancels out.
function M.spaceTaken()
  return cardHeight and cardHeight + CARD_GAP or height - 20
end

--- Options:
--- - historyFile: the CSV that widgets/epic.lua writes, as a full path
--- - title: shown at the top of the widget
--- - style: the look of the card, one of the styles in epic-themes.css (defaults to "glass")
function M.setup(options)
  M.options = options

  M.webview = hs.webview.new({ x = 0, y = 0, w = WIDTH, h = height })
    :windowStyle({ "borderless" })
    :transparent(true)
    :shadow(false)
    :allowTextEntry(false)
    :level(hs.drawing.windowLevels.desktopIcon)
    :behaviorAsLabels({ "canJoinAllSpaces", "stationary" })
    :navigationCallback(function(action)
      if action == "didFinishNavigation" then measureCard() end
    end)

  M.redraw = hs.timer.delayed.new(1, render)
  M.fileWatcher = hs.pathwatcher.new(options.historyFile, function() M.redraw:start() end):start()
  epic.onSnapshot = function() M.redraw:start() end
  M.screenWatcher = hs.screen.watcher.new(place):start()
  -- Picks up the new day after midnight, so today's figure shows as still in progress.
  M.dailyTimer = hs.timer.doEvery(30 * 60, render)

  render()
  place()
end

--- Shows the widget bottom right of the built-in screen, or hides it when the lid is shut.
function place()
  local screen = epic.builtInScreen()
  if not screen then
    M.webview:hide()
    return
  end
  local frame = screen:frame()
  M.webview:topLeft({ x = frame.x + frame.w - WIDTH, y = frame.y + frame.h - height }):show()
end

function render()
  local snapshot = todaysSnapshot()
  local catchUp = snapshot and snapshot.catchUp or {}
  resize(#catchUp)
  M.webview:html(epic.fillTemplate(TEMPLATE, {
    title = M.options.title,
    style = M.options.style or "glass",
    today = os.date("%Y-%m-%d"),
    days = readHistory(),
    catchUp = catchUp,
    pointsPerDay = snapshot and snapshot.pointsPerDay,
    mustPointsLeft = snapshot and snapshot.mustPointsLeft,
    workingDaysLeft = snapshot and snapshot.workingDaysLeft,
    maxRows = MAX_ROWS,
  }))
end

--- Reads the card's height once it's drawn, and moves the epic widget to sit just above it.
function measureCard()
  M.webview:evaluateJavaScript("document.getElementById('card').offsetHeight", function(result)
    local measured = tonumber(result)
    if not measured or measured == cardHeight then return end
    cardHeight = measured
    epic.place()
  end)
end

--- The epic widget's latest figures, e.g. the tickets to get to Ready for Testing today. Nil on a day
--- off, or before the epic widget has worked out today's figures.
function todaysSnapshot()
  local snapshot = epic.latestSnapshot
  if snapshot and snapshot.workingDay and snapshot.date == os.date("%Y-%m-%d") then return snapshot end
end

--- Fits the window to the catch-up list, and moves the epic widget to stay just above it.
function resize(ticketCount)
  local rows = math.min(ticketCount, MAX_ROWS)
  local newHeight = BASE_HEIGHT + (rows > 0 and LIST_HEADER_HEIGHT + rows * ROW_HEIGHT or 0)
  if newHeight == height then return end
  height = newHeight
  M.webview:size({ w = WIDTH, h = height })
  place()
  epic.place()
end

--- The history file's `date,days_ahead,points_ahead,points_complete` lines, oldest first. Days
--- recorded before those columns were added don't have them.
function readHistory()
  local days = {}
  for line in epic.readFile(M.options.historyFile):gmatch("[^\n]+") do
    local date, daysAhead, pointsAhead, pointsComplete =
      line:match("^(%d%d%d%d%-%d%d%-%d%d),([-%d.]+),?([-%d.]*),?([-%d.]*)")
    if date then
      table.insert(days, {
        date = date,
        daysAhead = tonumber(daysAhead),
        pointsAhead = tonumber(pointsAhead),
        pointsComplete = tonumber(pointsComplete),
      })
    end
  end
  return days
end

return M
