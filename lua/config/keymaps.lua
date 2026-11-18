-- Shortcuts that don't belong to a plugin. Plugin shortcuts live next to the
-- plugin in lua/plugins/. keys.txt lists all of them; keep it in sync.
local map = vim.keymap.set

-- Quick escape (from Danitell0's config)
map("i", "<C-j>", "<Esc>", { desc = "Leave insert mode" })
map("t", "<C-j>", "<C-\\><C-n>", { desc = "Leave terminal mode" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- VS Code basics
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<CR><Esc>", { desc = "Save" })
map("n", "<leader>W", "<cmd>wall<CR>", { desc = "Save all files" })
map("n", "<leader>Q", "<cmd>confirm qall<CR>", { desc = "Quit nvim" })
map("n", "<C-a>", "ggVG", { desc = "Select all" })
-- Ctrl+/ toggles comments. Terminals send it as Ctrl+_.
for _, lhs in ipairs({ "<C-/>", "<C-_>" }) do
	map("n", lhs, "gcc", { remap = true, desc = "Toggle comment" })
	map("v", lhs, "gc", { remap = true, desc = "Toggle comment" })
	map("i", lhs, "<Esc>gcca", { remap = true, desc = "Toggle comment" })
end

-- Move selected lines up/down; keep the selection when indenting
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down", silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up", silent = true })
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Paste over a selection without losing what you copied
map("x", "p", '"_dP', { desc = "Paste (keep clipboard)" })

-- Splits: move with Ctrl+h/j/k/l or Space+h/j/k/l
for _, dir in ipairs({ "h", "j", "k", "l" }) do
	map("n", "<C-" .. dir .. ">", "<C-w>" .. dir, { desc = "Go to split " .. dir })
	map("n", "<leader>" .. dir, "<C-w>" .. dir, { desc = "Go to split " .. dir })
end
map("n", "<leader>v", "<cmd>vsplit<CR>", { desc = "Split right" })
map("n", "<leader>-", "<cmd>split<CR>", { desc = "Split below" })
map("n", "<leader>q", "<cmd>close<CR>", { desc = "Close split" })
map("n", "<C-Up>", "<cmd>resize -3<CR>", { desc = "Shrink split" })
map("n", "<C-Down>", "<cmd>resize +3<CR>", { desc = "Grow split" })
map("n", "<C-Left>", "<cmd>vertical resize -5<CR>", { desc = "Narrower split" })
map("n", "<C-Right>", "<cmd>vertical resize +5<CR>", { desc = "Wider split" })

-- Open files are tabs at the top (bufferline). Tab / Shift+Tab cycle them.
map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next tab" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous tab" })
map("n", "<leader>w", function() Snacks.bufdelete() end, { desc = "Close tab" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Close other tabs" })
for i = 1, 9 do
	map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "Go to tab " .. i })
end

-- Run code (lua/config/run.lua)
map("n", "<leader>rr", function() require("config.run").file() end, { desc = "Run this file" })
map("n", "<F5>", function() require("config.run").file() end, { desc = "Run this file" })
map("n", "<leader>rm", function() require("config.run").make() end, { desc = "make" })
map("n", "<leader>rc", function() require("config.run").prompt() end, { desc = "Run a command…" })
map("n", "<leader>rl", function() require("config.run").again() end, { desc = "Run last command again" })

-- Errors and warnings
map("n", "gl", vim.diagnostic.open_float, { desc = "Show error under cursor" })
map("n", "]e", function() vim.diagnostic.jump({ count = 1, severity = "ERROR", float = true }) end,
	{ desc = "Next error" })
map("n", "[e", function() vim.diagnostic.jump({ count = -1, severity = "ERROR", float = true }) end,
	{ desc = "Previous error" })

-- This cheat sheet
map("n", "<leader>?", function() require("config.cheatsheet").open() end, { desc = "All shortcuts" })
