local M = {}

local HYPER = { "cmd", "alt", "ctrl", "shift" }
local HOME = os.getenv("HOME")

local ALACRITTY = "org.alacritty"
-- The second terminal runs as a separate copy of Alacritty started with these arguments. Two
-- windows in one copy can't be switched between reliably: macOS brings the app forward first and
-- sometimes raises the other window. With one window per copy there is nothing else to raise.
local SECOND_TERMINAL_ARGS = { "--title", "[2]" }

local isSecondTerminalByPid = {}

--- Whether this copy of Alacritty was started as the second terminal. Its launch arguments can't
--- change while it runs, so they are read once per process.
local function isSecondTerminal(app)
  local pid = app:pid()
  if isSecondTerminalByPid[pid] == nil then
    local args = hs.execute("ps -o args= -p " .. pid)
    isSecondTerminalByPid[pid] = args:find(table.concat(SECOND_TERMINAL_ARGS, " "), 1, true) ~= nil
  end
  return isSecondTerminalByPid[pid]
end

local function findTerminal(wantSecond)
  for _, app in ipairs(hs.application.applicationsForBundleID(ALACRITTY)) do
    if isSecondTerminal(app) == wantSecond then return app end
  end
end

-- Hammerspoon can garbage-collect a task that nothing references before it finishes.
local pendingLaunch

local function focusTerminal(wantSecond)
  local app = findTerminal(wantSecond)
  if app then return app:activate() end

  -- -n starts a new copy even when Alacritty is already running.
  local openArgs = { "-n", "-b", ALACRITTY }
  if wantSecond then
    table.insert(openArgs, "--args")
    for _, arg in ipairs(SECOND_TERMINAL_ARGS) do table.insert(openArgs, arg) end
  end
  pendingLaunch = hs.task.new("/usr/bin/open", nil, openArgs):start()
end

local bindings = {
  f = function() hs.open(HOME .. "/Downloads") end,
  l = function() hs.caffeinate.systemSleep() end,
  r = function() focusTerminal(false) end,
  u = function() focusTerminal(true) end,
}

function M.setup()
  for key, action in pairs(bindings) do
    hs.hotkey.bind(HYPER, key, action)
  end
end

return M
