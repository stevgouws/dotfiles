-- vim.opt.scrolloff = 999 -- really slow in vscode because of redraw
vim.opt.number = true

if vim.g.vscode then
    -- VSCode extension
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

vim.keymap.set("n", "<leader>lc", "/@voxsmartltd\\/components<CR>Wci\"file:../component-library/dist<ESC>", { desc = "Link Component Library" })

require("config.lazy")
-- require('mini.surround').setup()

-- highlight on yank: https://neovim.io/doc/user/lua.html#_vim.hl
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
})
