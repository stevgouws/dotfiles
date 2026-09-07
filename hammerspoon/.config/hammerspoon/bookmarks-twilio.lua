-- Twilio console bookmarks with a switchable active account.
--
-- Accounts live in twilio_sids.lua next to this file (gitignored) as a list
-- of { name = "...", sid = "..." } tables; the chosen account name is
-- persisted to $XDG_STATE_HOME/twilio_active_account.

local M = {}

local SIDS_MODULE = "twilio_sids"
local STATE_DIR = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
local STATE_FILE = STATE_DIR .. "/twilio_active_account"

local cache = { accounts = nil, active = nil }

local function loadAccounts()
  if cache.accounts then return cache.accounts end
  local ok, accounts = pcall(require, SIDS_MODULE)
  cache.accounts = (ok and type(accounts) == "table") and accounts or {}
  return cache.accounts
end

local function findAccount(name)
  local accounts = loadAccounts()
  for _, account in ipairs(accounts) do
    if account.name == name then return account end
  end
  return accounts[1]
end

local function readSavedName()
  local file = io.open(STATE_FILE, "r")
  if not file then return nil end
  local name = file:read("*l")
  file:close()
  return name
end

local function activeAccount()
  if not cache.active then
    cache.active = findAccount(readSavedName())
  end
  return cache.active
end

function M.setActive(name)
  local acct = findAccount(name)
  if not acct then return end
  cache.active = acct
  os.execute("mkdir -p " .. STATE_DIR)
  local f = io.open(STATE_FILE, "w")
  if f then
    f:write(acct.name .. "\n")
    f:close()
  end
end

function M.activeName()
  local acct = activeAccount()
  return acct and acct.name or nil
end

function M.url(path)
  local acct = activeAccount()
  if not acct then
    hs.alert.show("Twilio SIDs not configured — create " .. SIDS_MODULE .. ".lua in the hammerspoon config dir")
    return nil
  end
  return "https://1console.twilio.com/account/" .. acct.sid .. "/us1/" .. path
end

local function openConsole(path)
  return function()
    local url = M.url(path)
    if url then hs.urlevent.openURLWithBundle(url, "com.google.Chrome") end
  end
end

-- Pops a menu of accounts under the given menubar item and switches to the
-- one picked.
local function pickAccount(anchorMenubar)
  local activeName = M.activeName()
  local menuItems = {}
  for _, acct in ipairs(loadAccounts()) do
    table.insert(menuItems, {
      title = (acct.name == activeName and "● " or "○ ") .. acct.name,
      fn = function()
        M.setActive(acct.name)
        hs.alert.show("Twilio: " .. acct.name)
      end,
    })
  end
  local frame = anchorMenubar:frame()
  hs.menubar.new(false):setMenu(menuItems):popupMenu({ x = frame.x, y = frame.y + frame.h })
end

-- Returns a bookmark group entry for use in modes.lua's bookmark tables.
function M.bookmarks(anchorMenubar)
  return {
    name = function()
      local active = M.activeName()
      return "Twilio" .. (active and (" " .. active) or "")
    end,
    group = {
      l = { name = "Logs",             action = openConsole("messaging-logs/all") },
      t = { name = "Templates",        action = openConsole("templates/messaging/your-templates") },
      w = { name = "Whatsapp Senders", action = openConsole("senders-hub/list/whatsapp") },
      c = { name = "Change Account",   action = function() pickAccount(anchorMenubar) end },
    },
  }
end

return M
