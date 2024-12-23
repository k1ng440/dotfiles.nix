-- Use vscode launch config if available
local continue = function()
    if vim.fn.filereadable(".vscode/launch.json") then
        require("dap.ext.vscode").load_launchjs()
    end
    require("dap").continue()
end

return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "jay-babu/mason-nvim-dap.nvim",
            "nvim-telescope/telescope-dap.nvim",
            "nvim-neotest/nvim-nio",

            -- debuggers
            "leoluz/nvim-dap-go",
            "mfussenegger/nvim-dap-python",
        },
        keys = {
            {
                "<leader>dB",
                function()
                    require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
                end,
                desc = "Breakpoint Condition",
            },
            {
                "<leader>db",
                function()
                    require("dap").toggle_breakpoint()
                end,
                desc = "Toggle [B]reakpoint",
            },
            {
                "<leader>dr",
                function()
                    require("dap").repl.toggle()
                end,
                desc = "Toggle [R]EPL",
            },
            {
                "<leader>ds",
                function()
                    require("dap").session()
                end,
                desc = "[S]ession",
            },
            {
                "<leader>dp",
                function()
                    require("dap.ui.widgets").preview()
                end,
                desc = "[D]ap [P]review",
            },
            {
                "<leader>dh",
                function()
                    require("dap.ui.widgets").hover()
                end,
                desc = "[D]ap [H]over",
            },
            {
                "<leader>dC",
                function()
                    require("dap").run_to_cursor()
                end,
                desc = "Run to Cursor",
            },
            {
                "<leader>dg",
                function()
                    require("dap").goto_()
                end,
                desc = "Go to Line (No Execute)",
            },
            {
                "<leader>di",
                function()
                    require("dap").step_into()
                end,
                desc = "Step Into",
            },
            {
                "<leader>dj",
                function()
                    require("dap").down()
                end,
                desc = "Down",
            },
            {
                "<leader>dk",
                function()
                    require("dap").up()
                end,
                desc = "Up",
            },
            {
                "<leader>dl",
                function()
                    require("dap").run_last()
                end,
                desc = "Run Last",
            },
            {
                "<leader>do",
                function()
                    require("dap").step_out()
                end,
                desc = "Step Out",
            },
            {
                "<leader>dO",
                function()
                    require("dap").step_over()
                end,
                desc = "Step Over",
            },
            {
                "<leader>dp",
                function()
                    require("dap").pause()
                end,
                desc = "Pause",
            },
            { "<F5>", continue, "Debug: Start/Continue" },
            {
                "<F6>",
                function()
                    require("dap").run_last()
                end,
                desc = "Debug: Run Last",
            },
            {
                "<F9>",
                function()
                    require("dap").step_into()
                end,
                desc = "Debug: Step Into",
            },
            {
                "<F10>",
                function()
                    require("dap").step_over()
                end,
                desc = "Debug: Step Over",
            },
            {
                "<F11>",
                function()
                    require("dap").step_out()
                end,
                desc = "Debug: Step Out",
            },

            {
                "<F7>",
                function()
                    require("dapui").toggle()
                end,
                "Debug UI",
            },
            {
                "<leader>du",
                function()
                    require("dapui").toggle()
                end,
                desc = "Dap UI",
            },
            {
                "<leader>de",
                function()
                    require("dapui").eval()
                end,
                desc = "Eval",
                mode = { "n", "v" },
            },
        },
        cmd = {
            "DapContinue",
            "DapToggleBreakpoint",
            "DapToggleRepl",
            "DapStepOver",
            "DapStepInto",
            "DapStepOut",
            "DapTerminate",
            "DapLoadLaunchJSON",
            "DapRestartFrame",
        },

        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            local icons = require("k1ng.core.icons")

            require("telescope").load_extension("dap")
            require("mason-nvim-dap").setup({
                automatic_setup = true,
                ensure_installed = { "delve", "js-debug-adapter", "codelldb" },
                automatic_installation = true,
            })

            -- dap ui
            dapui.setup({
                icons = icons.dapui.ui,
                controls = { icons = require("k1ng.core.icons").dapui.controls },
            })
            dap.listeners.after.event_initialized["dapui_config"] = dapui.open
            dap.listeners.before.event_terminated["dapui_config"] = dapui.close
            dap.listeners.before.event_exited["dapui_config"] = dapui.close
            -- EOF dap ui

            -- virtual text
            require("nvim-dap-virtual-text").setup({
                enabled = true,
                enabled_commands = true,
                highlight_changed_variables = true,
                highlight_new_as_changed = false,
                show_stop_reason = true,
                commented = false,
                -- experimental features:
                virt_text_pos = "eol",
                all_frames = false,
                virt_lines = false,
                virt_text_win_col = nil,
            })
            -- EOF virtual text

            -- Golang
            require("dap-go").setup({
                delve = {
                    port = "43000",
                },
                dap_configurations = {
                    {
                        type = "go",
                        name = "Attach remote",
                        mode = "remote",
                        request = "attach",
                        connect = {
                            host = "127.0.0.1",
                            port = "43000",
                        },
                    },
                },
            })

            -- php
            dap.adapters.php = {
                type = "executable",
                command = "nodejs",
                args = { "/opt/vscode-php-debug/out/phpDebug.js" },
            }

            dap.configurations.php = {
                {
                    type = "php",
                    request = "launch",
                    name = "Listen for xdebug",
                    port = "9003",
                    log = true,
                    serverSourceRoot = "/srv/www/",
                    localSourceRoot = "/home/www/VVV/www/",
                },
            }
            -- EOF php

            -- JavaScript/TypeScript
            require("dap").adapters["pwa-node"] = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = {
                    command = "node",
                    args = {
                        require("mason-registry").get_package("js-debug-adapter"):get_install_path()
                            .. "/js-debug/src/dapDebugServer.js",
                        "${port}",
                    },
                },
            }

            for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
                if not dap.configurations[language] then
                    dap.configurations[language] = {
                        {
                            type = "pwa-node",
                            request = "launch",
                            name = "Launch file",
                            program = "${file}",
                            cwd = "${workspaceFolder}",
                        },
                        {
                            type = "pwa-node",
                            request = "attach",
                            name = "Attach",
                            processId = require("dap.utils").pick_process,
                            cwd = "${workspaceFolder}",
                        },
                    }
                end
            end
            -- EOF JavaScript

            -- lua
            dap.configurations.lua = {
                {
                    type = "nlua",
                    request = "attach",
                    name = "Attach to running Neovim instance",
                    host = function()
                        local value = vim.fn.input("Host [127.0.0.1]: ")
                        if value ~= "" then
                            return value
                        end
                        return "127.0.0.1"
                    end,
                    port = function()
                        local val = tonumber(vim.fn.input("Port: ", "54321"))
                        assert(val, "Please provide a port number")
                        return val
                    end,
                },
            }

            dap.adapters.nlua = function(callback, config)
                callback({ type = "server", host = config.host, port = config.port })
            end
            -- EOF lua

            -- Python
            local debugpy = require("mason-registry").get_package("debugpy"):get_install_path()
            require("dap-python").setup(debugpy .. "/venv/bin/python")
            -- EOF python

            -- CPlusPlus, C, Rust
            local codelldb_root = require("mason-registry").get_package("codelldb"):get_install_path() .. "/extension/"
            local codelldb_path = codelldb_root .. "adapter/codelldb"
            local liblldb_path = codelldb_root .. "lldb/lib/liblldb.so"
            dap.adapters.lldb = {
                type = "server",
                port = "${port}",
                host = "127.0.0.1",
                executable = {
                    command = codelldb_path,
                    args = { "--liblldb", liblldb_path, "--port", "${port}" },
                },
            }

            dap.configurations.cpp = {
                {
                    name = "Launch",
                    type = "lldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},

                    -- 💀
                    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
                    --
                    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
                    --
                    -- Otherwise you might get the following error:
                    --
                    --    Error on launch: Failed to attach to the target process
                    --
                    -- But you should be aware of the implications:
                    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
                    -- runInTerminal = false,
                },
            }

            dap.configurations.c = dap.configurations.cpp
            dap.configurations.rust = dap.configurations.cpp
            -- EOF CPlusPlus, C, Rust
        end,
    },
}
