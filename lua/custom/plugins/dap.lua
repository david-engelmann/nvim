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
      "jay-babu/mason-nvim-dap.nvim",
      'mfussenegger/nvim-dap-python',
    },
    config = function()
      local dap = require 'dap'
      local dap_python = require 'dap-python'
      local ui = require 'dapui'

      dap.set_log_level('TRACE')

      require('dapui').setup()
      require('dap-go').setup()
      --require('dap-python').setup("python")
      --require('dap-python').test_runner = 'pytest'
      --require('dap-python').resolve_python = function()
        --return '/usr/local/bin/python'
      --end

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
      
      dap.adapters.python = {
        type = 'executable',
        command = '/usr/local/bin/python',
        args = { '-m', 'debugpy.adapter' },
      }

      dap.adapters.python3 = {
        type = 'server',
        host = 'localhost',
        port = 5678,
      }
      dap.adapters.pytest = {
        type = 'server',
        host = 'localhost',
        port = 5679,
      }

--      dap.adapters.python = function(cb, config)
        --if config.request == 'attach' then
            --local port = (config.connect or config).port
            --cb({
                --type = 'server',
                --port = 5678,
                --host = '0.0.0.0',
            --})
        --else
            --cb({
                --type = 'executable',
                --command = '/usr/local/bin/python',
                --args = { '-m', 'debugpy.adapter' },
            --})
        --end
      --end


      local pythonLocalFileConfig = {
        type = 'python',
        request = 'launch',
        name = 'pytest: current file',
        args = {
          "${file}"
        },
        console = "integratedTerminal",
        module = "pytest",
        pythonPath = "/usr/local/bin/python",
      }

      local pythonLocalConfig = {
        type = 'python',
        request = 'launch',
        name = 'pytest',
        console = "integratedTerminal",
        module = "pytest",
        pythonPath = "/usr/local/bin/python",
      }

      local pythonLocalFolderConfig = {
        type = 'python',
        request = 'launch',
        name = 'pytest: current folder',
        args = {
          vim.fn.getcwd()
        },
        console = "integratedTerminal",
        module = "pytest",
        pythonPath = "/usr/local/bin/python",
      }

      local pythonAttachFileConfig = {
        type = 'python3',
        request = 'attach',
        connect = {
          port = 5678,
          host = 'localhost',
        },
        name = 'pytest: docker container - current file',
        console = 'integratedTerminal',
        module = 'pytest',
        pathMappings = {
          {
            localRoot = vim.fn.getcwd(),
            remoteRoot = '/code'
          }
        },
        args = {
          "${file}"
        },
        subProcess = false,
      }


      local pythonAttachConfig = {
        type = 'python3',
        request = 'attach',
        connect = {
          port = 5678,
          host = 'localhost',
        },
        --module = 'pytest',

        console = 'integratedTerminal',
        name = 'Attach to Docker - FastApi:main', 

        pathMappings = {
          {
            localRoot = '/Users/david/bg/bgv3',
            remoteRoot = '/code'
          }
        },
        subProcess = false,
      }

      local pythonAttachPytestConfig = {
        type = 'pytest',
        request = 'attach',
        connect = {
          port = 5679,
          host = 'localhost',
        },
        --module = 'pytest',
        name = 'Attach to Docker Pytest:all',
        console = 'integratedTerminal',

        pathMappings = {
          {
            localRoot = '/Users/david/bg/bgv3',
            remoteRoot = '/code',
          }
        },
        subProcess = false,
        args = { '-m', 'debugpy.adapter' },
      }
      --table.insert(require('dap').configurations.python, pythonAttachConfig)

      dap.configurations.python = {pythonLocalFileConfig, pythonLocalConfig, pythonLocalFolderConfig, pythonAttachFileConfig, pythonAttachConfig, pythonAttachPytestConfig}

      -- taken from above
        --mode = "remote",
        --module = "pytest",
        --args = {
          --"${file}"
        --},
        --pythonPath = "/usr/local/bin/python",
        --cwd = vim.fn.getcwd(),
        --subProcess = false,

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
      vim.keymap.set('n', '<F12>', dap.restart)
      vim.keymap.set('n', '<leader>dr', dap.repl.open)
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint)
      vim.keymap.set('n', '<leader>dB', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end)
      vim.keymap.set('n', '<leader>de', ui.eval)
      vim.keymap.set('n', '<leader>dE', function()
        ui.eval(vim.fn.input 'Expression: ')
      end)

      --vim.api.nvim_set_keymap("n", "<leader>dn", "<Cmd>lua require('dap-python').test_method()<CR>", {noremap = true, silent = true})
      --vim.api.nvim_set_keymap("n", "<leader>df", "<Cmd>lua require('dap-python').test_class()<CR>", {noremap = true, silent = true})
      --vim.api.nvim_set_keymap("v", "<leader>ds", "<Cmd>lua require('dap-python').debug_selection()<CR>", {noremap = true, silent = true})

      vim.api.nvim_set_keymap(
        'n',
        '<leader>df',
        "<Cmd>lua require('dap').run({type='python', request='attach', name='Attach to Docker - Python', connect={host='localhost', port=5678}, pathMappings={{localRoot='/Users/david/bg/bgv3', remoteRoot='/code'}}, args={'-m', 'pytest', '${file}'}})<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        'n',
        '<leader>dd',
        "<Cmd>lua require('dap').run({type='python', request='attach', name='Attach to Docker - Python', connect={host='localhost', port=5678}, pathMappings={{localRoot='/Users/david/bg/bgv3', remoteRoot='/code'}}, args={'-m', 'pytest', '${workspaceFolder}/'}})<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        'n',
        '<leader>da',
        "<Cmd>lua require('dap').run({type='python', request='attach', name='Attach to Docker - Python', connect={host='localhost', port=5678}, pathMappings={{localRoot='/Users/david/bg/bgv3', remoteRoot='/code'}}, args={'-m', 'pytest'}})<CR>",
        { noremap = true, silent = true }
      )

      -- python -m debugpy --listen 0.0.0.0:5678 -m uvicorn app.main:app --host 0.0.0.0 --port 8080

      -- Helper: check if port is open using nc (netcat)
      local function is_port_open(port)
        local result = vim.fn.system("nc -z localhost " .. port .. " 2>/dev/null && echo 'open' || echo 'closed'")
        return result:match("open") ~= nil
      end

      -- Helper: wait for port with polling using defer_fn
      local function wait_for_port_and_attach(port, attempts_left, callback)
        if attempts_left <= 0 then
          vim.notify("Timeout waiting for debugpy on port " .. port, vim.log.levels.ERROR)
          return
        end

        if is_port_open(port) then
          -- Port is open, but debugpy needs more time to fully initialize
          -- Wait 2 seconds before attaching to avoid ECONNRESET
          vim.notify("Port open, waiting for debugpy to initialize...", vim.log.levels.INFO)
          vim.defer_fn(callback, 2000)
        else
          -- Try again in 300ms
          vim.defer_fn(function()
            wait_for_port_and_attach(port, attempts_left - 1, callback)
          end, 300)
        end
      end

      -- Helper: kill any existing debugpy listener on the port (synchronous)
      local function kill_existing_debugpy()
        -- Kill any existing debugpy process in the container to free up port 5679
        vim.fn.system("docker exec bgv3_app pkill -f 'debugpy.*5679' 2>/dev/null || true")
        -- Wait a bit for the process to fully terminate and port to be released
        vim.fn.system("sleep 1")
      end

      local function run_pytest_docker(cmd)
        -- Kill any existing debugpy process first to avoid "Address already in use"
        vim.notify("Cleaning up old debugpy processes...", vim.log.levels.INFO)
        kill_existing_debugpy()

        -- Open terminal running pytest under debugpy
        vim.cmd("botright 15split new")
        vim.cmd("terminal docker exec -it bgv3_app python -m debugpy --wait-for-client --listen 0.0.0.0:5679 -m " .. cmd .. " --color=yes")
        vim.cmd("normal! G")
        -- Return focus to code window
        vim.cmd("wincmd p")

        -- Wait for debugpy to be ready (up to ~18 seconds: 60 attempts * 300ms)
        vim.notify("Waiting for debugpy to start...", vim.log.levels.INFO)
        wait_for_port_and_attach(5679, 60, function()
          vim.notify("Attaching debugger...", vim.log.levels.INFO)
          local dap = require('dap')
          dap.run({
            type = 'pytest',
            request = 'attach',
            name = 'Attach to Docker Pytest: auto',
            connect = { host = 'localhost', port = 5679 },
            pathMappings = {
              { localRoot = '/Users/david/bg/bgv3', remoteRoot = '/code' }
            },
            subProcess = false,
          })
        end)
      end


      local function convert_to_container_path(path)
        return path:gsub("^/Users/david/bg/bgv3/", "/code/")
      end
      
      -- Command to run the entire pytest suite
      vim.api.nvim_create_user_command("PytestSuite", function()
        run_pytest_docker("pytest /code/test")
      end, {})
      
      -- Command to run pytest on the current file
      vim.api.nvim_create_user_command("PytestFile", function()
        local file = convert_to_container_path(vim.fn.expand("%:p"))
        run_pytest_docker("pytest " .. file)
      end, {})
      
      -- Command to run pytest on the current folder
      vim.api.nvim_create_user_command("PytestFolder", function()
        local folder = convert_to_container_path(vim.fn.expand("%:p:h"))
        run_pytest_docker("pytest " .. folder)
      end, {})


      local function get_current_function_name()
        local ts_utils = require('nvim-treesitter.ts_utils')
        local node = ts_utils.get_node_at_cursor()
      
        while node do
          if node:type() == 'function_definition' then
            -- Get the first child with 'identifier' type for the function name
            for i = 0, node:named_child_count() - 1 do
              local child = node:named_child(i)
              if child:type() == 'identifier' then
                return vim.treesitter.get_node_text(child, 0)  -- Use this instead to get text directly
              end
            end
          end
          node = node:parent()
        end
      
        return nil
      end

      -- Command to run pytest on the current function
      vim.api.nvim_create_user_command("PytestFunction", function()
        local file = convert_to_container_path(vim.fn.expand("%:p"))
        local function_name = get_current_function_name()

        if function_name then
          run_pytest_docker("pytest " .. file .. "::" .. function_name)
        else
          print("No function name found at cursor position.")
        end
      end, {})

      vim.api.nvim_set_keymap("n", "<leader>ts", ":PytestSuite<CR>", { noremap = true, silent = true, desc = "Run entire pytest suite" })
      vim.api.nvim_set_keymap("n", "<leader>tf", ":PytestFile<CR>", { noremap = true, silent = true, desc = "Run pytest on current file" })
      vim.api.nvim_set_keymap("n", "<leader>td", ":PytestFolder<CR>", { noremap = true, silent = true, desc = "Run pytest on current folder" })
      vim.api.nvim_set_keymap("n", "<leader>tt", ":PytestFunction<CR>", { noremap = true, silent = true, desc = "Run pytest on current function" })

      dap.listeners.after.event_intialized.dapui_config = function()
        ui.open()
      end

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
