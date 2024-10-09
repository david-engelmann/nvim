return {
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'leoluz/nvim-dap-go',
      'mfussenegger/nvim-dap',
      "nvim-telescope/telescope-dap.nvim",
      "jbyuki/one-small-step-for-vimkind",
      'rcarriga/cmp-dap',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-neotest/nvim-nio',
      'williamboman/mason.nvim',
      'mfussenegger/nvim-dap-python',
    },
    config = function()
      local dap = require 'dap'
      local dap_python = require 'dap-python'
      local ui = require 'dapui'

      dap.set_log_level('TRACE')

      require('dapui').setup()
      require('dap-go').setup()
      require('dap-python').setup(vim.g.python3_host_prog)
      require('dap-python').test_runner = 'pytest'

      require('nvim-dap-virtual-text').setup {
        -- This just tries to mitigate the chance that I leak tokens here. Probably won't stop it from happening...
        enabled = true,

        enabled_commands = false,

        highlight_changed_variables = true,
        highlight_new_as_changed = true,

        commented = false,

        show_stop_reason = true,

        virt_text_pos = 'eol',

        all_frames = false,

        display_callback = function(variable)
          local name = string.lower(variable.name)
          local value = string.lower(variable.value)
          if name:match 'secret' or name:match 'api' or value:match 'secret' or value:match 'api' then
            return '*****'
          end

          if #variable.value > 15 then
            return ' ' .. string.sub(variable.value, 1, 15) .. '... '
          end

          return ' ' .. variable.value
        end,
      }

      local pythonAttachConfig = {
        type = 'python',
        request = 'attach',
        connect = {
          port = 5678,
          host = 'localhost',
        },
        mode = "remote",
        name = "Attach to Docker - Python",
        cwd = vim.fn.getcwd(),
        pathMappings = {
          {
            localRoot = vim.fn.getcwd(),
            remoteRoot = function()
              return '/code'
            end,
          }
        }
      }
      table.insert(require('dap').configurations.python, pythonAttachConfig)



      --dap_python.setup("python")
      --dap_python.test_runner = "pytest"

      --dap.adapters.python = {
        --type = "executable",
        --command = "/usr/local/bin/python",
        --args = { "-m", "debugpy.adapter" },
      --}

      --dap.adapters.python = {
        --type = 'server',
        --host = '0.0.0.0',
        --port = 5678,
      --}

      --dap.configurations.python = {
        --{
          --type = 'python',
          --request = 'launch',
          --name = 'pytest: current file',
          --args = {
            --"${file}"
          --},
          --console = "integratedTerminal",
          --module = "pytest",
          --pythonPath = "/usr/local/bin/python", 
        --},
        --{
          --type = 'python',
          --request = 'launch',
          --name = 'pytest',
          --console = "integratedTerminal",
          --module = "pytest",
          --pythonPath = "/usr/local/bin/python",
        --},
        --{
          --type = 'python',
          --request = 'attach',
          --name = 'pytest: docker container - current file',
          --console = "integratedTerminal",
          --module = "pytest",
          --pathMappings = {{
            --localRoot = vim.fn.getcwd(),
            --remoteRoot = "/code"
          --}},
          --args = {
            --"${file}"
          --},
          --subProcess = false,

        --},
        --{
          --type = 'python',
          --request = 'attach',
          --name = 'pytest: docker container',
          --console = "integratedTerminal",
          --module = "pytest",
          --pathMappings = {{
            --localRoot = vim.fn.getcwd(),
            --remoteRoot = "/code"
          --}},

          --subProcess = false,
        --},
      --}

      --dap_python.setup {
        --adapter = 'python',
        --configurations = {
          --{
            --type = 'python',
            --request = 'attach',
            --name = 'Attach to Docker',
            --host = 'localhost',
            --port = 5678,
            --justMyCode = false,
          --}
        --}
      --}


      --dap.configurations.python = {
        --{
          --type = 'python',
          --request = 'launch',
          --name = 'launch file',
          --program = "${file}",
          --pythonPath = function()
            --return '/usr/local/bin/python'
          --end;
        --}
      --}


      -- Handled by nvim-dap-go
      -- dap.adapters.go = {
      --   type = "server",
      --   port = "${port}",
      --   executable = {
      --     command = "dlv",
      --     args = { "dap", "-l", "127.0.0.1:${port}" },
      --   },
      -- }

      vim.keymap.set('n', '<space>b', dap.toggle_breakpoint)
      vim.keymap.set('n', '<space>gb', dap.run_to_cursor)

      -- Eval var under cursor
      vim.keymap.set('n', '<space>?', function()
        require('dapui').eval(nil, { enter = true })
      end)

      vim.keymap.set('n', '<F1>', dap.continue)
      vim.keymap.set('n', '<F2>', dap.step_into)
      vim.keymap.set('n', '<F3>', dap.step_over)
      vim.keymap.set('n', '<F4>', dap.step_out)
      vim.keymap.set('n', '<F5>', dap.step_back)
      vim.keymap.set('n', '<F13>', dap.restart)

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
    end,
  },
}
