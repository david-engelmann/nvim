return {
  {
    "nvim-telescope/telescope.nvim",
    tag = '0.1.2',
    lazy = false,
    dependencies = {
      {"nvim-lua/plenary.nvim"},
      {"BurntSushi/ripgrep"},
      {"sharkdp/fd"},
    },
    priority = 100,
    config = function()
      require "david.telescope.setup"
      require "david.telescope.keys"
    end,
    --dev = true,
  },
  "nvim-telescope/telescope-file-browser.nvim",
  "nvim-telescope/telescope-hop.nvim",
  "nvim-telescope/telescope-ui-select.nvim",
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  {
    "ThePrimeagen/git-worktree.nvim",
    config = function()
      require("git-worktree").setup {}
    end,
  },
  {
    "AckslD/nvim-neoclip.lua",
    config = function()
      require("neoclip").setup()
    end,
  },
}
