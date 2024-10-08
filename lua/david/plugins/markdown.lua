return {
    'MeanderingProgrammer/render-markdown.nvim',
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugint 
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        render_modes = { 'n', 'c' },
        enable = true,
        injections = {
            gitcommit = {
                enabled = true,
                query = [[
                    ((message) @injection.content
                        (#set! injection.combined)
                        (#set! injection.include-children)
                        (#set! injection.language "markdown"))
                ]],
            },
        },
        max_file_size = 10.0,
        debounce = 100,


    },
}