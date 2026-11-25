--- A desktop widget, below the epic widget, charting how many days ahead or short the epic was
--- at the end of each working day, to show whether it's catching up or falling further behind. It
--- reads the history file that widgets/epic.lua writes, and redraws whenever that file changes. The
--- card itself is widgets/epic_history.html.
local M = {}

local epic = require("widgets.epic")

-- Declared up front so the helpers further down stay local to this file but can still be called from setup.
local place, render, readHistory

local TEMPLATE = hs.configdir .. "/widgets/epic_history.html"

-- Fits the 360px-wide card plus the page padding in epic_history.html, with little to spare so the
-- epic card sits just above it. Anything taller than HEIGHT is cut off, so raise it if the card grows.
local WIDTH, HEIGHT = 400, 280

--- How much of the bottom of the screen this widget takes up, for the epic widget to leave free. Its
--- window's top padding overlaps the epic window's bottom padding, so the gap between the two cards is
--- no bigger than the gap to the screen edge.
M.height = HEIGHT - 20

--- Options:
--- - historyFile: the CSV that widgets/epic.lua writes, as a full path
--- - title: shown at the top of the widget
--- - style: the look of the card, one of the styles in epic-themes.css (defaults to "glass")
function M.setup(options)
  M.options = options

  M.webview = hs.webview.new({ x = 0, y = 0, w = WIDTH, h = HEIGHT })
    :windowStyle({ "borderless" })
    :transparent(true)
    :shadow(false)
    :allowTextEntry(false)
    :level(hs.drawing.windowLevels.desktopIcon)
    :behaviorAsLabels({ "canJoinAllSpaces", "stationary" })

  M.redraw = hs.timer.delayed.new(1, render)
  M.fileWatcher = hs.pathwatcher.new(options.historyFile, function() M.redraw:start() end):start()
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
  M.webview:topLeft({ x = frame.x + frame.w - WIDTH, y = frame.y + frame.h - HEIGHT }):show()
end

function render()
  M.webview:html(epic.fillTemplate(TEMPLATE, {
    title = M.options.title,
    style = M.options.style or "glass",
    today = os.date("%Y-%m-%d"),
    days = readHistory(),
  }))
end

--- The history file's `date,days_ahead` lines, oldest first.
function readHistory()
  local days = {}
  for date, daysAhead in epic.readFile(M.options.historyFile):gmatch("(%d%d%d%d%-%d%d%-%d%d),([-%d.]+)") do
    table.insert(days, { date = date, daysAhead = tonumber(daysAhead) })
  end
  return days
end

return M
