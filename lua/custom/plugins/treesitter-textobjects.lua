return {"nvim-treesitter-textobjects",

after  = { "nvim-treesitter/nvim-treesitter" },
config = function()
  require'nvim-treesitter.configs'.setup {
      textobjects = {
          select = {
              enable = true,
              lookahead = true,
              keymaps = {
                  ["af"] = "@function.outer",
                  ["if"] = "@function.inner",
                  ["ac"] = "@class.outer",
                  ["ic"] = "@class.inner",
              },
          },
      },
  }
  end
}