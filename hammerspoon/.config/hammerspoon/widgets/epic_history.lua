--- A desktop widget, on the right half of the MacBook's own screen beside the epic widget, charting how many days ahead or short the epic was
--- at the end of each working day, to show whether it's catching up or falling further behind, how
--- many points are done today against a day's worth and the pace to hit the due date, and when it's
--- short, which tickets to get to Ready for Testing today to catch up. It reads the history file that
--- widgets/epic.lua writes, and redraws whenever that file or the epic widget's figures change. The
--- card itself is widgets/epic_history.html.
local M = {}

local epic = require("widgets.epic")

-- Declared up front so the helpers further down stay local to this file but can still be called from setup.
local place, render, todaysSnapshot, readHistory

local TEMPLATE = hs.configdir .. "/widgets/epic_history.html"

-- Past this many tickets, the catch-up list's last row says how many more there are.
local MAX_ROWS = 10

--- Options:
--- - historyFile: the CSV that widgets/epic.lua writes, as a full path
--- - title: shown at the top of the widget
--- - style: the look of the card, one of the styles in epic-themes.css (defaults to "glass")
function M.setup(options)
  M.options = options

  M.webview = hs.webview.new({ x = 0, y = 0, w = 735, h = 923 })
    :windowStyle({ "borderless" })
    :transparent(true)
    :shadow(false)
    :allowTextEntry(false)
    :level(hs.drawing.windowLevels.desktopIcon)
    :behaviorAsLabels({ "canJoinAllSpaces", "stationary" })

  M.redraw = hs.timer.delayed.new(1, render)
  M.fileWatcher = hs.pathwatcher.new(options.historyFile, function() M.redraw:start() end):start()
  epic.onSnapshot = function() M.redraw:start() end
  M.screenWatcher = hs.screen.watcher.new(place):start()
  -- Picks up the new day after midnight, so today's figure shows as still in progress.
  M.dailyTimer = hs.timer.doEvery(30 * 60, render)

  render()
  place()
end

function place()
  epic.placeHalf(M.webview, "right", render)
end

function render()
  local snapshot = todaysSnapshot()
  local catchUp = snapshot and snapshot.catchUp or {}
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

--- The epic widget's latest figures, e.g. the tickets to get to Ready for Testing today. Nil on a day
--- off, or before the epic widget has worked out today's figures.
function todaysSnapshot()
  local snapshot = epic.latestSnapshot
  if snapshot and snapshot.workingDay and snapshot.date == os.date("%Y-%m-%d") then return snapshot end
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
