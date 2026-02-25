return {
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'leoluz/nvim-dap-go',
      'mfussenegger/nvim-dap',
      'nvim-telescope/telescope-dap.nvim',
      'jbyuki/one-small-step-for-vimkind',
      'rcarriga/cmp-dap',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-neotest/nvim-nio',
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      'mfussenegger/nvim-dap-python',
    },
    config = function()
      local dap = require 'dap'
      local ui = require 'dapui'

      dap.set_log_level 'TRACE'
      require('dapui').setup()
      require('dap-go').setup()

      require('nvim-dap-virtual-text').setup {
        enabled = true,
        enabled_commands = false,
        highlight_changed_variables = true,
        highlight_new_as_changed = true,
        commented = false,
        show_stop_reason = true,
        virt_text_pos = 'eol',
        all_frames = false,
        display_callback = function(variable)
          local name = string.lower(variable.name or '')
          local value = string.lower(variable.value or '')
          if name:match 'secret' or name:match 'api' or value:match 'secret' or value:match 'api' then
            return ' *****'
          end
          if variable.value and #variable.value > 15 then
            return ' ' .. string.sub(variable.value, 1, 15) .. '... '
          end
          return ' ' .. (variable.value or '')
        end,
      }

      local python_bin = vim.fn.exepath 'python3'
      if python_bin == '' then
        python_bin = '/usr/local/bin/python'
      end

      local profiles = {
        bgv3 = {
          label = 'bgv3',
          kind = 'docker',
          container = 'bgv3_app',
          remote_root = '/code',
          test_root = '/code/test',
          host_app_port = 5678,
          host_pytest_port = 5679,
          container_pytest_port = 5679,
          markers = { 'app/main.py' },
        },
        staging_refresh = {
          label = 'staging-refresh',
          kind = 'compose',
          service = 'staging-refresh',
          remote_root = '/app',
          test_root = '/app/tests',
          host_app_port = tonumber(vim.env.STAGING_REFRESH_DEBUGPY_APP_PORT) or 5688,
          host_pytest_port = tonumber(vim.env.STAGING_REFRESH_DEBUGPY_PYTEST_PORT) or 5689,
          container_pytest_port = 5679,
          markers = { 'code/refresh.py', 'tests/test_refresh_end_to_end.py' },
        },
      }

      local forced_profile = nil

      local function path_exists(path)
        return vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1
      end

      local function find_repo_root()
        local file = vim.api.nvim_buf_get_name(0)
        local start = (file ~= '' and vim.fs.dirname(file)) or vim.loop.cwd()
        local git_dir = vim.fs.find('.git', { path = start, upward = true })[1]
        if git_dir then
          return vim.fs.dirname(git_dir)
        end
        return vim.loop.cwd()
      end

      local function detect_profile(root)
        if path_exists(root .. '/code/refresh.py') and path_exists(root .. '/tests/test_refresh_end_to_end.py') then
          return 'staging_refresh'
        end
        return 'bgv3'
      end

      local function current_profile()
        local root = find_repo_root()
        local key = forced_profile
        if not key or not profiles[key] then
          key = detect_profile(root)
        end
        return profiles[key], root, key
      end

      local function system_exec(profile, root, inner_cmd)
        local inner = vim.fn.shellescape(inner_cmd)
        if profile.kind == 'compose' then
          return 'cd ' .. vim.fn.shellescape(root) .. ' && docker compose exec -T ' .. profile.service .. ' sh -lc ' .. inner
        end
        return 'docker exec ' .. profile.container .. ' sh -lc ' .. inner
      end

      local function terminal_exec(profile, root, inner_cmd)
        local inner = vim.fn.shellescape(inner_cmd)
        if profile.kind == 'compose' then
          return 'cd ' .. vim.fn.shellescape(root) .. ' && docker compose exec ' .. profile.service .. ' sh -lc ' .. inner
        end
        return 'docker exec -it ' .. profile.container .. ' sh -lc ' .. inner
      end

      local function convert_to_container_path(path)
        local profile, root = current_profile()
        if path:sub(1, #root) == root then
          return profile.remote_root .. path:sub(#root + 1)
        end
        return path
      end

      dap.adapters.python = {
        type = 'executable',
        command = python_bin,
        args = { '-m', 'debugpy.adapter' },
      }

      dap.adapters.python3 = function(cb, _)
        local profile = current_profile()
        cb({
          type = 'server',
          host = '127.0.0.1',
          port = profile.host_app_port,
        })
      end

      dap.adapters.pytest = function(cb, _)
        local profile = current_profile()
        cb({
          type = 'server',
          host = '127.0.0.1',
          port = profile.host_pytest_port,
        })
      end

      local python_local_file = {
        type = 'python',
        request = 'launch',
        name = 'pytest: current file',
        args = { '${file}' },
        console = 'integratedTerminal',
        module = 'pytest',
        pythonPath = python_bin,
      }

      local python_local_all = {
        type = 'python',
        request = 'launch',
        name = 'pytest',
        console = 'integratedTerminal',
        module = 'pytest',
        pythonPath = python_bin,
      }

      local python_local_folder = {
        type = 'python',
        request = 'launch',
        name = 'pytest: current folder',
        args = { vim.fn.getcwd() },
        console = 'integratedTerminal',
        module = 'pytest',
        pythonPath = python_bin,
      }

      dap.configurations.python = { python_local_file, python_local_all, python_local_folder }

      local function is_port_open(port)
        local result = vim.fn.system("nc -z localhost " .. port .. " 2>/dev/null && echo 'open' || echo 'closed'")
        return result:match 'open' ~= nil
      end

      local function wait_for_port_and_attach(port, attempts_left, callback)
        if attempts_left <= 0 then
          vim.notify('Timeout waiting for debugpy on port ' .. port, vim.log.levels.ERROR)
          return
        end
        if is_port_open(port) then
          vim.defer_fn(callback, 1000)
        else
          vim.defer_fn(function()
            wait_for_port_and_attach(port, attempts_left - 1, callback)
          end, 300)
        end
      end

      local function attach_pytest()
        local profile, root = current_profile()
        dap.run {
          type = 'pytest',
          request = 'attach',
          name = 'Attach to Docker Pytest: auto (' .. profile.label .. ')',
          connect = { host = '127.0.0.1', port = profile.host_pytest_port },
          pathMappings = {
            { localRoot = root, remoteRoot = profile.remote_root },
          },
          subProcess = false,
          justMyCode = false,
        }
      end

      local function kill_existing_debugpy()
        local profile, root = current_profile()
        local kill_cmd = "pkill -f 'debugpy.*" .. profile.container_pytest_port .. "' || true"
        vim.fn.system(system_exec(profile, root, kill_cmd))
        vim.fn.system 'sleep 1'
      end

      local function run_pytest_docker(cmd)
        local profile, root = current_profile()
        vim.notify('Cleaning up old debugpy processes...', vim.log.levels.INFO)
        kill_existing_debugpy()

        vim.cmd 'botright 15split new'
        local debug_cmd = 'python -m debugpy --wait-for-client --listen 0.0.0.0:'
          .. profile.container_pytest_port
          .. ' -m '
          .. cmd
          .. ' --color=yes'
        vim.cmd('terminal ' .. terminal_exec(profile, root, debug_cmd))
        vim.cmd 'normal! G'
        vim.cmd 'wincmd p'

        vim.notify(
          'Waiting for debugpy (' .. profile.label .. ') on localhost:' .. profile.host_pytest_port .. '...',
          vim.log.levels.INFO
        )

        wait_for_port_and_attach(profile.host_pytest_port, 60, function()
          vim.notify('Attaching debugger...', vim.log.levels.INFO)
          attach_pytest()
        end)
      end

      local function get_current_function_name()
        local ok, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
        if not ok then
          return nil
        end

        local node = ts_utils.get_node_at_cursor()
        while node do
          if node:type() == 'function_definition' then
            for i = 0, node:named_child_count() - 1 do
              local child = node:named_child(i)
              if child:type() == 'identifier' then
                return vim.treesitter.get_node_text(child, 0)
              end
            end
          end
          node = node:parent()
        end
        return nil
      end

      local function register_user_command(name, fn)
        pcall(vim.api.nvim_del_user_command, name)
        vim.api.nvim_create_user_command(name, fn, {})
      end

      register_user_command('DapProfile', function(opts)
        local arg = (opts.args or ''):gsub('^%s+', ''):gsub('%s+$', '')
        if arg == '' then
          vim.ui.select({ 'auto', 'bgv3', 'staging_refresh' }, { prompt = 'Select DAP profile' }, function(choice)
            if not choice then
              return
            end
            if choice == 'auto' then
              forced_profile = nil
            else
              forced_profile = choice
            end
            local _, _, key = current_profile()
            vim.notify('DAP profile: ' .. key, vim.log.levels.INFO)
          end)
          return
        end

        if arg == 'auto' then
          forced_profile = nil
          local _, _, key = current_profile()
          vim.notify('DAP profile: ' .. key, vim.log.levels.INFO)
          return
        end

        if profiles[arg] then
          forced_profile = arg
          vim.notify('DAP profile: ' .. arg, vim.log.levels.INFO)
          return
        end

        vim.notify('Unknown profile: ' .. arg, vim.log.levels.ERROR)
      end)

      register_user_command('PytestSuite', function()
        local profile = current_profile()
        run_pytest_docker('pytest ' .. profile.test_root)
      end)

      register_user_command('PytestFile', function()
        local file = convert_to_container_path(vim.fn.expand '%:p')
        run_pytest_docker('pytest ' .. file)
      end)

      register_user_command('PytestFolder', function()
        local folder = convert_to_container_path(vim.fn.expand '%:p:h')
        run_pytest_docker('pytest ' .. folder)
      end)

      register_user_command('PytestFunction', function()
        local file = convert_to_container_path(vim.fn.expand '%:p')
        local function_name = get_current_function_name()
        if function_name then
          run_pytest_docker('pytest ' .. file .. '::' .. function_name)
        else
          vim.notify('No function name found at cursor position.', vim.log.levels.WARN)
        end
      end)

      vim.keymap.set('n', '<space>b', dap.toggle_breakpoint)
      vim.keymap.set('n', '<space>gb', dap.run_to_cursor)
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

      vim.keymap.set('n', '<leader>ts', ':PytestSuite<CR>', { noremap = true, silent = true, desc = 'Run entire pytest suite' })
      vim.keymap.set('n', '<leader>tf', ':PytestFile<CR>', { noremap = true, silent = true, desc = 'Run pytest on current file' })
      vim.keymap.set('n', '<leader>td', ':PytestFolder<CR>', { noremap = true, silent = true, desc = 'Run pytest on current folder' })
      vim.keymap.set('n', '<leader>tt', ':PytestFunction<CR>', { noremap = true, silent = true, desc = 'Run pytest on current function' })
      vim.keymap.set('n', '<leader>tp', ':DapProfile<CR>', { noremap = true, silent = true, desc = 'Select DAP profile' })

      dap.listeners.after.event_initialized.dapui_config = function()
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
