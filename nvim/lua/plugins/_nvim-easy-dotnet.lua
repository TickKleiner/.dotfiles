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
        end,
        picker = "snacks",
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

      local function rebuild_project(co, path)
        local spinner = require("easy-dotnet.ui-modules.spinner").new()
        spinner:start_spinner("Building")
        vim.fn.jobstart(string.format("dotnet build %s", path), {
          on_exit = function(_, return_code)
            if return_code == 0 then
              spinner:stop_spinner("Built successfully")
            else
              spinner:stop_spinner("Build failed with exit code " .. return_code, vim.log.levels.ERROR)
              error("Build failed")
            end
            coroutine.resume(co)
          end,
        })
        coroutine.yield()
      end

      for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
        dap.configurations[lang] = {
          {
            type = "coreclr",
            name = "build & debug - netcoredbg",
            request = "launch",
            env = function()
              local dll = ensure_dll()
              local vars = dotnet.get_environment_variables(dll.project_name, dll.relative_project_path)
              return vars or nil
            end,
            program = function()
              local dll = ensure_dll()
              local co = coroutine.running()
              rebuild_project(co, dll.project_path)
              return dll.relative_dll_path
            end,
            cwd = function()
              local dll = ensure_dll()
              return dll.relative_project_path
            end,
          },
          {
            type = "coreclr",
            name = "test - netcoredbg",
            request = "attach",
            processId = function()
              local res = require("easy-dotnet").experimental.start_debugging_test_project()
              return res.process_id
            end,
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
