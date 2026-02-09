return {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({})

      local api = require("supermaven-nvim.api")

      api.restart()
      --api.logout()
      --api.use_pro()
    end,
  }