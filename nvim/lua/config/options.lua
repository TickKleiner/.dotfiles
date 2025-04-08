-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

if vim.g.neovide then
  -- Put anything you want to happen only in Neovide here
  vim.o.guifont = "FiraCode Nerd Font Mono:h14" -- text below applies for VimScript
  vim.opt.linespace = 2

  -- vim.g.neovide_opacity = 0.8
  -- vim.g.neovide_normal_opacity = 0.8
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_cursor_animate_in_insert_mode = true
end

require("dap").adapters.coreclr = {
  type = "executable",
  command = "netcoredbg",
  args = { "--interpreter=vscode" },
}

local dap_utils = require("dap.utils")

local function get_dll()
  return coroutine.create(function(dap_run_co)
    local items = vim.fn.globpath(vim.fn.getcwd(), "**/bin/**/Debug/**/*.dll", false, 1)
    local opts = {
      format_item = function(path)
        return vim.fn.fnamemodify(path, ":t")
      end,
    }
    local function cont(choice)
      if choice == nil then
        return nil
      else
        coroutine.resume(dap_run_co, choice)
      end
    end

    vim.ui.select(items, opts, cont)
  end)
end

require("dap").configurations.cs = {
  {
    type = "coreclr",
    name = "launch dll - netcoredbg",
    request = "launch",
    cwd = "${workspaceFolder}",
    program = get_dll,
    args = {},
  },
  {
    type = "coreclr",
    name = "attach - netcoredbg",
    request = "attach",
    processId = function()
      return dap_utils.pick_process()
    end,
    stopOnEntry = true,
  },
}
