local twilio = require("modes.bookmarks-twilio")

local M = {}

function M.setup(opts)
  local twilioMode = hs.hotkey.modal.new(opts.globalLeader, "t")
  local bookmarks = twilio.bookmarks(opts.modeStatus)

  opts.bindModeStatus(twilioMode, bookmarks.name, opts.borderColor)

  for key, entry in pairs(bookmarks.group) do
    twilioMode:bind("", key, function()
      twilioMode:exit()
      entry.action()
    end)
  end

  opts.bindExitKeys(twilioMode)

  return twilioMode
end

return M
