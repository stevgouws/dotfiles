-- vim.opt.scrolloff = 999 -- really slow in vscode because of redraw
vim.opt.number = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.clipboard = "unnamed"
vim.opt.gdefault = true

vim.g.mapleader = " "

-- Use OSC52 to yank over ssh

vim.g.clipboard = {
  name = 'osc52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}

if vim.g.vscode then
    -- VSCode extension
    -- Auto-format on leaving insert mode in VSCode Neovim
    -- vim.api.nvim_create_autocmd("InsertLeave", {
    --   callback = function()
    --     vim.cmd("call VSCodeNotify('editor.action.formatDocument')")
    --   end
    -- })
  -- remap window focus for vscode too
  -- local vscode = require("vscode")
else
  -- ordinary Neovim
  vim.opt.relativenumber = true -- not needed VScode provides it anyway
end

vim.keymap.set("n", "J", "20j", { noremap = true, silent = true })
vim.keymap.set("v", "J", "20j", { noremap = true, silent = true })
vim.keymap.set("n", "K", "20k", { noremap = true, silent = true })
vim.keymap.set("v", "K", "20k", { noremap = true, silent = true })

-- give <C-a> to tmux prefix
-- Disable Ctrl-a / Ctrl-x default behavior
vim.keymap.set('n', '<C-a>', '<Nop>', { noremap = true })
vim.keymap.set('n', '<C-x>', '<Nop>', { noremap = true })

-- Use + and - for increment/decrement instead
vim.keymap.set({ "v", "n" }, '+', '<C-a>', { noremap = true })
vim.keymap.set({ "v", "n" }, '-', '<C-x>', { noremap = true })

-- don't overwrite yank on paste
vim.keymap.set("x", "p", function()
  return '"_d"' .. vim.v.register .. 'P'
end, { expr = true, noremap = true, desc = "Paste in visual mode without overwriting the source register" })

vim.keymap.set("n", "<leader>j", "J", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader>s", "s", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>c", "cc", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>lc", "/\"@voxsmartltd/components\"<CR>Wci\"file:../component-library/dist<ESC>:w<CR>", { desc = "Link Component Library" })
vim.keymap.set("n", "<leader>lx", function()
  local keys = vim.api.nvim_replace_termcodes(
    [[/\vx1-components": "\^<CR>Wci"file:../../../vx1-component-library/dist<Esc>]],
    true, false, true
  )
  vim.api.nvim_feedkeys(keys, "n", false)
  vim.cmd([[%s%vs-fe-vx1-components-lib%vx1-component-library%ge]])
  vim.cmd("w")
end, { desc = "Link VX1 Component Library", silent = true })
vim.keymap.set("n", "<leader>lu", "/\"@voxsmartltd/frontend-utils\"<CR>Wci\"file:../../../fe-utils-library/dist<ESC>:w<CR>", { desc = "Link Utils Lib" })


vim.keymap.set("n", "<leader>mo", "?test(\\|it(<CR>ea.only<ESC>", { desc = "Mark: Wrap current testcase in .only" }) -- need to double escape pipe
vim.keymap.set("n", "<leader>mO", "?.only(<CR>dt(<ESC>", { desc = "Mark: Delete current testcase .only" })
vim.keymap.set("n", "<leader>ms", "?test(\\|it(<CR>ea.skip<ESC>", { desc = "Mark: Wrap current testcase in .skip" }) -- need to double escape pipe
vim.keymap.set("n", "<leader>mS", "?.skip(<CR>dt(<ESC>", { desc = "Mark: Delete current testcase .skip" })


vim.keymap.set("n", "<leader>ta", "yiwkO<ESC>pb~Itype <ESC>$aArgs = {}<ESC>i<CR><ESC>O", { desc = "Types: ArgsType" })
vim.keymap.set("n", "<leader>tp", "yiwkO<ESC>pbItype <ESC>$aProps = {}<ESC>i<CR><ESC>O", { desc = "Types: PropsType" })

-- Get current git branch name (fallback if not in a repo)
local function git_branch()
  local result = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")
  if vim.v.shell_error ~= 0 or not result[1] or result[1] == "" then
    return "no-branch"
  end
  return result[1]
end

vim.keymap.set("n", "<leader>rn", function()
  local root = vim.fn.getcwd()        -- VSCode workspace root
  local branch = git_branch()

  vim.fn.jobstart({
    "/Applications/Alacritty.app/Contents/MacOS/alacritty",
    "msg",
    "create-window",
    "--title", branch,
    "--working-directory", root,
  }, {
    detach = true,
  })
  -- 2) Bring Alacritty to the foreground
  vim.fn.jobstart({
    "osascript",
    "-e",
    'tell application "Alacritty" to activate',
  }, {
    detach = true,
  })

end, { silent = true })

require("config.lazy")

-- highlight on yank: https://neovim.io/doc/user/lua.html#_vim.hl
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Replace undefined with line in current Block
vim.api.nvim_create_user_command('Null', function()
  -- find the “{” above (backward, no wrap)…
  local open = vim.fn.searchpairpos('{', '', '}', 'bnW')
  -- and the “}” below (forward, no wrap)
  local close = vim.fn.searchpairpos('{', '', '}', 'nW')

  local start_line = open[1]
  local end_line   = close[1]

  if start_line == 0 or end_line == 0 then
    vim.notify("No enclosing { … } block found", vim.log.levels.WARN)
    return
  end

  -- run the substitute on those lines
  vim.cmd(string.format("%d,%ds/null/undefined/g", start_line, end_line))
end, {
  desc  = "Replace all `null` with `undefined` in the nearest {…} block",
  nargs = 0,
})

-- Toggle search highlights
vim.keymap.set('n', '<leader>/', ':set hlsearch!<CR>', { desc = 'Toggle search highlight' })

-- Case-insensitive searching, unless pattern contains uppercase
vim.o.ignorecase = true
vim.o.smartcase  = true

-- Override weird Y not yanking whole line https://chatgpt.com/c/6890b23f-4700-8320-a68e-a9a446394ef9
vim.keymap.del('n', 'Y')  -- clear the unwanted mapping
vim.keymap.set('n', 'Y', 'yy', { noremap = true, silent = true, desc = 'Yank whole line' })
--
---- Leap: always show labels at the beginning of the match
---- https://github.com/ggandor/leap.nvim?tab=readme-ov-file
---- `on_beacons` hooks into `beacons.light_up_beacons`, the function
---- responsible for displaying stuff.
--require('leap').opts.on_beacons = function (targets, _, _)
  --for _, t in ipairs(targets) do
    ---- Overwrite the `offset` value in all beacons.
    ---- target.beacon looks like: { <offset>, <extmark_opts> }
    --if t.label and t.beacon then t.beacon[1] = 0 end
  --end
  ---- Returning `true` tells `light_up_beacons` to continue as usual
  ---- (`false` would short-circuit).
  --return true
--end

-- Leap recommended customisations as per https://github.com/ggandor/leap.nvim?tab=readme-ov-file

-- Exclude whitespace and the middle of alphabetic words from preview:
--   foobar[baaz] = quux
--   ^----^^^--^^-^-^--^
require('leap').opts.preview_filter =
  function (ch0, ch1, ch2)
    return not (
      ch1:match('%s') or
      ch0:match('%a') and ch1:match('%a') and ch2:match('%a')
    )
  end

-- Define equivalence classes for brackets and quotes, in addition to the default whitespace group:
-- require('leap').opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }

-- Use the traversal keys to repeat the previous motion without explicitly invoking Leap:
require('leap.user').set_repeat_keys('<enter>', '<backspace>')

vim.keymap.set("n", "<leader>tt", function()
  local function exists(path)
    return vim.uv.fs_stat(path) ~= nil
  end

  local file = vim.fn.expand("%:p")
  local dir = vim.fn.fnamemodify(file, ":h")
  local name = vim.fn.fnamemodify(file, ":t")
  local stem = vim.fn.fnamemodify(file, ":t:r")
  local ext = vim.fn.fnamemodify(file, ":e")

  local test_file = file

  -- If not already a test file, look for .test or .spec
  if not name:match("%.test%.[^.]+$") and not name:match("%.spec%.[^.]+$") then
    local test_candidate = string.format("%s/%s.test.%s", dir, stem, ext)
    local spec_candidate = string.format("%s/%s.spec.%s", dir, stem, ext)

    if exists(test_candidate) then
      test_file = test_candidate
    elseif exists(spec_candidate) then
      test_file = spec_candidate
    else
      vim.notify("No matching test file found for " .. name, vim.log.levels.WARN)
      return
    end
  end

  -- project root → session name
  local root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
  if not root or root == "" then
    root = vim.fn.getcwd()
  end

  local session = vim.fn.fnamemodify(root, ":t")

  local cmd = string.format(
    'tmux has-session -t %q 2>/dev/null || tmux new -ds %q; tmux send-keys -t %q %q C-m',
    session,
    session,
    session,
    "clear && clear && npx vitest run " .. test_file
  )

  os.execute(cmd)
end)

-- open PR on remote
vim.keymap.set("n", "<leader>rp", function()
  vim.fn.jobstart("gh pr view --web", { detach = true })
end, { desc = "Open PR in browser" })

vim.keymap.set("n", "<leader>rc", function()
  local word = vim.fn.expand("<cword>")

  local target
  if word:match("^[0-9a-fA-F]+$") then
    target = word
  else
    target = "HEAD"
  end

  vim.fn.jobstart({ "gh", "browse", target }, { detach = true })
end, { desc = "Open commit (cursor or HEAD) in browser" })
