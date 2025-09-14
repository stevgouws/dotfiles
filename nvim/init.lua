-- vim.opt.scrolloff = 999 -- really slow in vscode because of redraw
vim.opt.number = true
if vim.g.vscode then
    -- VSCode extension
    -- Auto-format on leaving insert mode in VSCode Neovim
    -- vim.api.nvim_create_autocmd("InsertLeave", {
    --   callback = function()
    --     vim.cmd("call VSCodeNotify('editor.action.formatDocument')")
    --   end
    -- })
else
  -- ordinary Neovim
  vim.opt.relativenumber = true -- not needed VScode provides it anyway
end
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.clipboard = "unnamed"
vim.opt.gdefault = true

vim.g.mapleader = " "
vim.keymap.set("n", "J", "20j", { noremap = true, silent = true })
vim.keymap.set("v", "J", "20j", { noremap = true, silent = true })
vim.keymap.set("n", "K", "20k", { noremap = true, silent = true })
vim.keymap.set("v", "K", "20k", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>j", "J", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader>s", "s", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>c", "cc", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>lc", "/\"@voxsmartltd/components\"<CR>Wci\"file:../component-library/dist<ESC>:w<CR>", { desc = "Link Component Library" })
vim.keymap.set("n", "<leader>lx", function()
  local keys = vim.api.nvim_replace_termcodes(
    [[/\vx1-components": "\^<CR>Wci"file:../vx1-component-library/dist<Esc>]],
    true, false, true
  )
  vim.api.nvim_feedkeys(keys, "n", false)
  vim.cmd([[%s%vs-fe-vx1-components-lib%vx1-component-library%ge]])
  vim.cmd("w")
end, { desc = "Link VX1 Component Library", silent = true })

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
