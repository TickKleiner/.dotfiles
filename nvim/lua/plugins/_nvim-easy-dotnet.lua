return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
      local logPath = vim.fn.stdpath("data") .. "\\easy-dotnet\\build.log"
      local dotnet = require("easy-dotnet")

      dotnet.setup({
        terminal = function(path, action)
          local commands = {
            run = function()
              return "dotnet run --project " .. path
            end,
            test = function()
              return "dotnet test " .. path
            end,
            restore = function()
              return "dotnet restore --configfile " .. os.getenv("NUGET_CONFIG") .. " " .. path
            end,
            build = function()
              return "dotnet build  " .. path .. " /flp:v=q /flp:logfile=" .. logPath
            end,
          }

          local function filter_warnings(line)
            if not line:find("warning") then
              return line:match("^(.+)%((%d+),(%d+)%)%: (.+)$")
            end
          end

          local overseer_components = {
            { "on_complete_dispose", timeout = 30 },
            "default",
            { "unique", replace = true },
            {
              "on_output_parse",
              parser = {
                diagnostics = {
                  { "extract", filter_warnings, "filename", "lnum", "col", "text" },
                },
              },
            },
            {
              "on_result_diagnostics_quickfix",
              open = true,
              close = true,
            },
          }

          if action == "run" or action == "test" then
            table.insert(overseer_components, { "restart_on_save", paths = { LazyVim.root.git() } })
          end

          local command = commands[action]()
          local task = require("overseer").new_task({
            strategy = {
              "toggleterm",
              use_shell = false,
              direction = "horizontal",
              open_on_start = false,
            },
            name = action,
            cmd = command,
            cwd = LazyVim.root.git(),
            components = overseer_components,
          })
          task:start()
        end,
      })
    end,
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      -- Ensure dotnet debugger is installed
      "williamboman/mason.nvim",
      optional = true,
      opts = { ensure_installed = { "netcoredbg" } },
    },
    opts = function()
      local dap = require("dap")
      if not dap.adapters["netcoredbg"] then
        require("dap").adapters["netcoredbg"] = {
          type = "executable",
          command = vim.fn.exepath("netcoredbg"),
          args = { "--interpreter=vscode" },
          -- console = "internalConsole",
        }
      end
      local dotnet = require("easy-dotnet")
      local debug_dll = nil
      local function ensure_dll()
        if debug_dll ~= nil then
          return debug_dll
        end
        local dll = dotnet.get_debug_dll()
        debug_dll = dll
        return dll
      end
      require("overseer").register_template({
        name = "Build .NET App",
        builder = function(params)
          local logPath = vim.fn.stdpath("data") .. "\\easy-dotnet\\build.log"
          local function filter_warnings(line)
            if not line:find("warning") then
              return line:match("^(.+)%((%d+),(%d+)%)%: (.+)$")
            end
          end
          return {
            name = "build",
            cmd = "dotnet build /flp:v=q /flp:logfile=" .. logPath,
            components = {
              { "on_complete_dispose", timeout = 30 },
              "default",
              { "unique", replace = true },
              {
                "on_output_parse",
                parser = {
                  diagnostics = {
                    { "extract", filter_warnings, "filename", "lnum", "col", "text" },
                  },
                },
              },
              {
                "on_result_diagnostics_quickfix",
                open = true,
                close = true,
              },
            },
            cwd = require("easy-dotnet").get_debug_dll().relative_project_path,
          }
        end,
      })
      for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
        dap.configurations[lang] = {
          {
            log_level = "DEBUG",
            type = "netcoredbg",
            justMyCode = false,
            stopAtEntry = false,
            name = "build & debug - netcoredbg",
            request = "launch",
            env = function()
              local dll = ensure_dll()
              local vars = dotnet.get_environment_variables(dll.project_name, dll.relative_project_path)
              return vars or nil
            end,
            program = function()
              require("overseer").enable_dap()
              local dll = ensure_dll()
              return dll.relative_dll_path
            end,
            cwd = function()
              local dll = ensure_dll()
              return dll.relative_project_path
            end,
            preLaunchTask = "Build .NET App",
          },
          {
            type = "coreclr",
            name = "attach - netcoredbg",
            request = "attach",
            processId = function()
              return require("dap.utils").pick_process()
            end,
            stopOnEntry = true,
          },
        }
        dap.listeners.before["event_terminated"]["easy-dotnet"] = function()
          debug_dll = nil
        end
      end
    end,
  },
}
