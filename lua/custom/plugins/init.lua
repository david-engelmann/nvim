-- TODO:
--  - train.nvim
--  - streamer.nvim
--  - { "AndrewRadev/splitjoin.vim", keys = { "gJ", "gS" }, }
--  - "pwntester/octo.nvim"
--  - neogit
--  - neorg
--  - which-key.nvim
--  - nvim-treesitter-context
--  - danymat/neogen
--  -     use "monaqa/dial.nvim"
--  -     use "gyim/vim-boxdraw"
--  -     use { "tjdevries/vim-inyoface", config = function() vim.api.nvim_set_keymap("n", "<leader>cc", "<Plug>(InYoFace_Toggle)", {}) end, }
--  - ~/plugins/stackmap.nvim

return {
  { "nvim-lua/plenary.nvim", dev = false },
  { dir = "~/plugins/streamer-tools" },
  { dir = "~/plugins/ocaml.nvim", config = true },
  { dir = "~/plugins/train.nvim" },
  { dir = "~/plugins/monkey.nvim" },
  { dir = "~/plugins/vim9jit" },
  { dir = "~/plugins/sg.nvim" },
  { dir = "~/plugins/sponge-bob.nvim" },
  { "tjdevries/colorbuddy.nvim", dev = false },
  { "tjdevries/ocaml.nvim" },
  { "tjdevries/gruvbuddy.nvim", dev = false },
  { "tjdevries/cyclist.vim" },
  { "tjdevries/express_line.nvim", dev = false },
  { "tjdevries/overlength.vim" },
  { dir = "~/plugins/complextras.nvim" },

  -- "~/plugins/diff-therapy.nvim",
  -- "~/plugins/pastery.vim",

  { "tjdevries/green_light.nvim" },

  "milisims/nvim-luaref",
  "tpope/vim-surround",
  "godlygeek/tabular", -- Quickly align text by pattern
  "tpope/vim-repeat", -- Repeat actions better
  "tpope/vim-abolish", -- Cool things with words!
  "tpope/vim-characterize", -- ?
  "tpope/vim-scriptease",
  "tpope/vim-fugitive",
  "tpope/vim-commentary",
  "romainl/vim-qf",
  -- "christoomey/vim-tmux-navigator",
  -- "tmux-plugins/vim-tmux-focus-events",

  "mkitt/tabline.vim",
  "monaqa/dial.nvim",

  -- make transparent
  {"xiyaowong/transparent.nvim",
   config = function()
    require("transparent").setup({
      groups = { -- table: default groups
        'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
        'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
        'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
        'SignColumn', 'CursorLineNr', 'EndOfBuffer',
      },
      extra_groups = {"NormalFloat", "NvimTreeNormal", "TelescopeNormal"}, -- table: additional groups that should be cleared
      exclude_groups = {"NotifyBackground"}, -- table: groups you don't want to clear
    })
    end,
  },
  {
    "folke/which-key.nvim",
    lazy = false,
  },

  {
    "luukvbaal/statuscol.nvim",
    config = function()
      require("statuscol").setup {
        setopt = true,
      }
    end,
  },

  {
    "glacambre/firenvim",
    build = function()
      vim.fn["firenvim#install"](0)
    end,
  },

  "projekt0n/github-nvim-theme",
}
