-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

if vim.g.neovide then
  -- Put anything you want to happen only in Neovide here
  vim.o.guifont = "FiraCode Nerd Font Mono:h14" -- text below applies for VimScript
  vim.opt.linespace = 2

  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0

  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5

  -- vim.g.neovide_opacity = 0.8
  -- vim.g.neovide_normal_opacity = 0.8
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_cursor_animate_in_insert_mode = true

  vim.g.experimental_layer_grouping = false
  vim.g.snacks_animate = false
end
vim.opt.shellslash = false
vim.defer_fn(function()
  vim.opt.shellslash = false
end, 5000)
