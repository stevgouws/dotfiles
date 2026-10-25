local M = {}

local HYPER = { "cmd", "alt", "ctrl", "shift" }
local HOME = os.getenv("HOME")

local bindings = {
  f = function() hs.open(HOME .. "/Downloads") end,
  l = function() hs.caffeinate.systemSleep() end,
}

function M.setup()
  for key, action in pairs(bindings) do
    hs.hotkey.bind(HYPER, key, action)
  end
end

return M
