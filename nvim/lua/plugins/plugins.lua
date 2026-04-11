return {
--   "folke/neodev.nvim",
--  "folke/which-key.nvim",
-- { "folke/neoconf.nvim", cmd = "Neoconf" },
--   "kylechui/nvim-surround",
 --  { 'echasnovski/mini.surround', version = '*' },
   { "tpope/vim-surround", event = "VeryLazy" },
   { "tpope/vim-repeat", event = "VeryLazy" },
   { "tpope/vim-abolish",
    event = "VeryLazy",
    config = function()
      -- coerce to dash/kebab case
      vim.keymap.set({ "n", "x" }, "crk", "cr-", { remap = true, silent = true })
      -- coerce to MixedCase/TitleCase
      vim.keymap.set({ "n", "x" }, "crt", "crm", { remap = true, silent = true })
    end,
   },
   {
     "ggandor/leap.nvim",
     dependencies = { "tpope/vim-repeat" },
     url = "https://codeberg.org/andyg/leap.nvim",
     config = function()
--       require("leap").add_default_mappings()
        vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
--        vim.keymap.set('n',             'S', '<Plug>(leap-from-window)')
        vim.keymap.set({'n', 'x', 'o'}, 'S',  '<Plug>(leap-backward)')
     end,
   },
  --  {
  --   "numToStr/Comment.nvim",
  --   config = function()
  --     require("Comment").setup {
  --       -- your opts here
  --     }
  --   end
  -- }
   {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
    { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
    { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
    { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
}
}
