return {
--   "folke/neodev.nvim",
--  "folke/which-key.nvim",
-- { "folke/neoconf.nvim", cmd = "Neoconf" },
--   "kylechui/nvim-surround",
 --  { 'echasnovski/mini.surround', version = '*' },
   { "tpope/vim-surround", event = "VeryLazy" },
   { "tpope/vim-repeat", event = "VeryLazy" },
   { "tpope/vim-abolish", event = "VeryLazy" },
   {
     "ggandor/leap.nvim",
     dependencies = { "tpope/vim-repeat" },
     url = "https://codeberg.org/andyg/leap.nvim",
     config = function()
       require("leap").add_default_mappings()
     end,
   },
   {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup {
        -- your opts here
      }
    end
  } 
}
