--- A desktop widget, top right of the MacBook's own screen, showing how an epic is doing against its
--- due date. Everything it shows comes from Obsidian: the epic's ticket notes, the epic note's due
--- date, and Estimation.md for the points-to-days scale, BAU, bank holidays and leave (the layout the
--- epic-tracking Claude skill sets up). It redraws whenever a note changes. The card itself is
--- widgets/epic.html.
local M = {}

-- Declared up front so the helpers further down stay local to this file but can still be called from setup.
local place, builtInScreen, render, epicData, readFile, frontmatter, unquote, hasValue, asList

local TEMPLATE = hs.configdir .. "/widgets/epic.html"

-- Fits the 360px-wide card plus the page padding in epic.html. Anything taller than HEIGHT is cut
-- off, so raise it if the card gets more rows.
local WIDTH, HEIGHT = 400, 470

--- Options:
--- - vault: the Obsidian vault folder
--- - title: shown at the top of the widget
--- - epicNote: the epic note, relative to the vault; its `due` property is the due date
--- - tag: the tag on every ticket note in the epic
--- - assignee: only this person's tickets are counted
--- - style: the look of the card, one of the styles in epic.html (defaults to "glass")
function M.setup(options)
  M.options = options

  M.webview = hs.webview.new({ x = 0, y = 0, w = WIDTH, h = HEIGHT })
    :windowStyle({ "borderless" })
    :transparent(true)
    :shadow(false)
    :allowTextEntry(false)
    :level(hs.drawing.windowLevels.desktopIcon)
    :behaviorAsLabels({ "canJoinAllSpaces", "stationary" })

  M.redraw = hs.timer.delayed.new(2, render)

  -- Obsidian rewrites its own settings in .obsidian all the time, so only notes trigger a redraw.
  M.vaultWatcher = hs.pathwatcher.new(options.vault, function(paths)
    for _, path in ipairs(paths) do
      if path:match("%.md$") then
        M.redraw:start()
        return
      end
    end
  end):start()

  M.screenWatcher = hs.screen.watcher.new(place):start()
  -- Picks up the new day after midnight.
  M.dailyTimer = hs.timer.doEvery(30 * 60, render)

  render()
  place()
end

--- Shows the widget top right of the built-in screen, or hides it when the lid is shut.
function place()
  local screen = builtInScreen()
  if not screen then
    M.webview:hide()
    return
  end
  local frame = screen:frame()
  M.webview:topLeft({ x = frame.x + frame.w - WIDTH, y = frame.y }):show()
end

function builtInScreen()
  for _, screen in ipairs(hs.screen.allScreens()) do
    if (screen:name() or ""):match("Built%-in") then
      return screen
    end
  end
end

--- Redraws the card. If reading the notes fails, the card shows the error rather than going blank
--- or staying out of date, and it's printed to the Hammerspoon console.
function render()
  local ok, data = pcall(epicData)
  if not ok then
    print("Epic widget: " .. tostring(data))
    data = { error = tostring(data), style = M.options.style }
  end
  local template = readFile(TEMPLATE)
  local json = hs.json.encode(data)
  -- A function replacement, because gsub would treat any "%" in the JSON as a capture reference.
  M.webview:html((template:gsub("__DATA__", function()
    return json
  end)))
end

function epicData()
  local options = M.options
  local scale = frontmatter(readFile(options.vault .. "/Estimation.md"))
  local epic = frontmatter(readFile(options.vault .. "/" .. options.epicNote))

  local tickets = {}
  local ticketsDir = options.vault .. "/tickets"
  for name in hs.fs.dir(ticketsDir) do
    if name:match("%.md$") then
      local note = frontmatter(readFile(ticketsDir .. "/" .. name))
      if hasValue(note.tags, options.tag) and note.assignee == options.assignee then
        local points = tonumber(note.points)
        table.insert(tickets, {
          status = note.status,
          stretch = note.stretch == "true",
          points = points or 0,
          days = points and tonumber(scale["with_ai_" .. points]) or 0,
        })
      end
    end
  end

  local daysOff = {}
  for _, key in ipairs({ "bank_holidays", "leave" }) do
    for _, date in ipairs(asList(scale[key])) do
      table.insert(daysOff, date)
    end
  end

  return {
    title = options.title,
    style = options.style or "glass",
    today = os.date("%Y-%m-%d"),
    due = epic.due,
    bauDaysPerWeek = tonumber(scale["with_ai_" .. tostring(scale.bau_points_per_week)]) or 0,
    tickets = tickets,
    daysOff = daysOff,
  }
end

function readFile(path)
  local file = io.open(path)
  if not file then
    return ""
  end
  local text = file:read("a")
  file:close()
  return text
end

--- Just enough YAML for these notes: `key: value` lines, and lists of `- item` lines (a key with no
--- value) or `[]`. An empty value, like `points:` on a ticket that isn't pointed, becomes an empty list.
function frontmatter(text)
  local block = text:match("^%-%-%-\n(.-)\n%-%-%-")
  local result = {}
  local listKey
  for line in ((block or "") .. "\n"):gmatch("(.-)\n") do
    local item = line:match("^%s+%-%s+(.-)%s*$")
    local key, value = line:match("^([%w_-]+):%s*(.-)%s*$")
    if item and listKey then
      table.insert(result[listKey], unquote(item))
    elseif key then
      listKey = nil
      if value == "" or value == "[]" then
        result[key] = {}
        listKey = value == "" and key or nil
      else
        result[key] = unquote(value)
      end
    end
  end
  return result
end

function unquote(value)
  return (value:gsub('^"(.*)"$', "%1"))
end

--- A property as a list, so a single `leave: 2026-12-24` works as well as a list of dates.
function asList(value)
  if type(value) == "table" then
    return value
  end
  return value and { value } or {}
end

function hasValue(list, wanted)
  for _, value in ipairs(asList(list)) do
    if value == wanted then
      return true
    end
  end
  return false
end

return M
