--- Switches between a tmux session and the VS Code window for the same project, and back.
---
--- The two are matched by name: a session's directory is opened with `code .`, so the VS Code
--- window's folder name is the same as the session name. This relies on VS Code's
--- `window.title` setting being just `${rootName}`, so the window title is the folder name.
local M = {}

local TMUX = "/opt/homebrew/bin/tmux"
local CODE = "/opt/homebrew/bin/code"
local VSCODE_BUNDLE_ID = "com.microsoft.VSCode"
local ALACRITTY_BUNDLE_ID = "org.alacritty"

-- Declared up front so the helpers below stay local to this file while sitting under their caller.
local openInVSCode, switchToTmux, listClients, clientInApp, alacrittyAppFor, findVSCodeWindow,
  exactTarget

-- Hammerspoon can garbage-collect a task that nothing references before it finishes.
local pendingTask

function M.setup(opts)
  hs.hotkey.bind(opts.meh, "j", M.toggle)
end

--- From Alacritty, goes to the VS Code window for the tmux session on screen. From VS Code, goes
--- to the tmux session for the focused window's project. From anywhere else, just focuses VS Code.
function M.toggle()
  local app = hs.application.frontmostApplication()
  local bundleID = app:bundleID()
  if bundleID == ALACRITTY_BUNDLE_ID then return openInVSCode(app) end
  if bundleID == VSCODE_BUNDLE_ID then return switchToTmux(app) end
  hs.application.launchOrFocusByBundleID(VSCODE_BUNDLE_ID)
end

function openInVSCode(alacrittyApp)
  local client = clientInApp(alacrittyApp)
  if not client then return hs.alert.show("No tmux session in this window") end

  local window = findVSCodeWindow(client.session)
  if window then return window:focus() end

  -- `code` brings the window forward if the folder is already open, e.g. on another Space where
  -- Hammerspoon can't see it, and opens a new window otherwise.
  pendingTask = hs.task.new(CODE, nil, { client.path }):start()
end

function switchToTmux(vscodeApp)
  local window = vscodeApp:focusedWindow()
  if not window then return end
  local session = window:title()

  local client = listClients()[1]
  if not client then return hs.alert.show("No terminal is attached to tmux") end

  local _, switched = hs.execute(
    TMUX .. " switch-client -c " .. client.tty .. " -t " .. exactTarget(session))
  if not switched then return hs.alert.show("No tmux session called " .. session) end

  local terminal = alacrittyAppFor(client.pid)
  if terminal then terminal:activate() end
end

--- tmux attaches each terminal window as a separate client. Returns them newest activity first.
---
--- The fields are split with "|" rather than tabs because Hammerspoon runs tmux without a UTF-8
--- locale, and tmux then prints tabs as "_".
function listClients()
  local output = hs.execute(TMUX .. " list-clients -F "
    .. "'#{client_activity}|#{client_pid}|#{client_tty}|#{session_name}|#{session_path}'")
  local clients = {}
  for line in (output or ""):gmatch("[^\n]+") do
    local activity, pid, tty, session, path = line:match("^(%d+)|(%d+)|([^|]+)|([^|]+)|(.+)$")
    if activity then
      table.insert(clients, {
        activity = tonumber(activity), pid = tonumber(pid), tty = tty, session = session, path = path,
      })
    end
  end
  table.sort(clients, function(a, b) return a.activity > b.activity end)
  return clients
end

--- The tmux client running inside this Alacritty process, so the right session is picked when
--- several Alacritty windows each show a different one.
function clientInApp(alacrittyApp)
  for _, client in ipairs(listClients()) do
    local app = alacrittyAppFor(client.pid)
    if app and app:pid() == alacrittyApp:pid() then return client end
  end
end

--- Walks up from a tmux client's process (tmux → zsh → login → Alacritty) to its Alacritty app.
function alacrittyAppFor(pid)
  local appByPid = {}
  for _, app in ipairs(hs.application.applicationsForBundleID(ALACRITTY_BUNDLE_ID)) do
    appByPid[app:pid()] = app
  end

  for _ = 1, 6 do
    if appByPid[pid] then return appByPid[pid] end
    -- Wrapped in brackets to pass on only the output: hs.execute also returns a status, which
    -- tonumber would take as the number base.
    pid = tonumber((hs.execute("ps -o ppid= -p " .. pid)))
    if not pid or pid <= 1 then return nil end
  end
end

function findVSCodeWindow(projectName)
  local vscode = hs.application.get(VSCODE_BUNDLE_ID)
  if not vscode then return nil end
  for _, window in ipairs(vscode:allWindows()) do
    if window:title() == projectName then return window end
  end
end

--- A leading `=` makes tmux match the session name exactly rather than by prefix, so "UUI-25"
--- can't land on "UUI-2587".
function exactTarget(session)
  return "'=" .. session:gsub("'", "") .. "'"
end

return M
