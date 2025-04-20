-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local del = vim.keymap.del

-- For conciseness
local opts = { noremap = true, silent = true }

-- delete single character without copying into register
map("n", "x", '"_x', opts)

-- -- Keep last yanked
-- map({ "n", "v" }, "<leader>d", '"_d', opts)
-- map({ "n", "v" }, "<leader>c", '"_c', opts)
-- map({ "x" }, "<leader>p", '"_dP', opts)

-- Vertical scroll and center
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)

-- Find and center
map("n", "n", "nzzzv", opts)
map("n", "N", "Nzzzv", opts)

-- quit file
map("n", "<C-q>", function()
  Snacks.bufdelete()
end)

-- del resize window using <ctrl> arrow keys
del("n", "<C-Up>")
del("n", "<C-Down>")
del("n", "<C-Left>")
del("n", "<C-Right>")

-- Window navigation using arrow keys
map("n", "<C-Left>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-Down>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-Up>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-Right>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl-shift> arrow keys
map("n", "<C-S-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-S-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines using arrow keys
map("n", "<A-Down>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-Up>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-Down>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-Up>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- buffers
map("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- zk
local wk = require("which-key")
wk.add({
  { "<leader>z", group = "notes" }, -- group
})
map("n", "<leader>zb", "<cmd>ZkBacklinks<cr>", { desc = "Backlink picker" })
map("n", "<leader>zd", "<cmd>ZkCd<cr>", { desc = "Change directory" })
map("n", "<leader>zl", "<cmd>ZkLinks<cr>", { desc = "Link picker" })
map("n", "<leader>zm", "<cmd>ZkFullTextSearch<cr>", { desc = "Search (FTS)" })
map("n", "<leader>zn", "<cmd>ZkNew { title = vim.fn.input('Title: ')}<cr>", { desc = "New note" })
map("n", "<leader>zr", "<cmd>ZkIndex<cr>", { desc = "Refresh index" })
map("n", "<leader>zs", "<cmd>ZkNotes { sort = { 'created' } }<cr>", { desc = "Search" })
map("n", "<leader>zt", "<cmd>ZkTags<cr>", { desc = "Tags" })

-- native snippets. only needed on < 0.11, as 0.11 creates these by default
if vim.fn.has("nvim-0.11") == 0 then
  del("s", "<Tab>")
  del({ "i", "s" }, "<S-Tab>")
end
