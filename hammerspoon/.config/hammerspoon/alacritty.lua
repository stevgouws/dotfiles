--- Switches between numbered Alacritty windows, e.g. one kept on each screen.
---
--- Each window runs in its own instance of Alacritty. Two windows in one instance can't be
--- switched between reliably: macOS brings the app forward first and sometimes raises the other
--- window. With one window per instance there is nothing else to raise.
---
--- Instance 1 starts with no arguments, so it keeps the blank title from alacritty.toml. Every
--- other instance n starts with the title "[n]", which is also how it's recognised later.
local M = {}

local BUNDLE_ID = "org.alacritty"

local function launchArgs(number)
  if number == 1 then return {} end
  return { "--title", "[" .. number .. "]" }
end

local instanceNumberByPid = {}

--- Which numbered instance this Alacritty process is. Its launch arguments can't change while it
--- runs, so they are read once per process.
local function instanceNumber(app)
  local pid = app:pid()
  if instanceNumberByPid[pid] == nil then
    local args = hs.execute("ps -o args= -p " .. pid)
    instanceNumberByPid[pid] = tonumber(args:match("%-%-title %[(%d+)%]")) or 1
  end
  return instanceNumberByPid[pid]
end

local function findInstance(number)
  for _, app in ipairs(hs.application.applicationsForBundleID(BUNDLE_ID)) do
    if instanceNumber(app) == number then return app end
  end
end

-- Hammerspoon can garbage-collect a task that nothing references before it finishes.
local pendingLaunch

--- Switches to Alacritty instance `number`, starting it if it isn't running.
function M.focusInstance(number)
  local app = findInstance(number)
  if app then return app:activate() end

  -- -n starts a new instance even when Alacritty is already running.
  local openArgs = { "-n", "-b", BUNDLE_ID }
  local args = launchArgs(number)
  if #args > 0 then
    table.insert(openArgs, "--args")
    for _, arg in ipairs(args) do table.insert(openArgs, arg) end
  end
  pendingLaunch = hs.task.new("/usr/bin/open", nil, openArgs):start()
end

return M
