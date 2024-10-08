return {
  {
    'kndndrj/nvim-dbee',
    enabled = true,
    dependencies = { 'MunifTanjim/nui.nvim' },
    build = function()
      require('dbee').install()
    end,
    config = function()
      local source = require 'dbee.sources'
      require('dbee').setup {
        sources = {
          source.MemorySource:new({
            ---@diagnostic disable-next-line: missing-fields
            {
              type = 'postgres',
              name = 'neondb',
              url = 'postgresql://neondb_owner:password@localhost:5432/neondb',
            },
          }, 'mixery'),
        },
      }
      require 'custom.dbee'
    end,
  },
}
