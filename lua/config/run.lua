-- "Run" button: saves, then runs the current file (or make) in a terminal
-- at the bottom that stays open so you can read the output. The terminal is
-- fish, so the commands stick to syntax fish and bash share.
local M = {}

local last

-- How to run each filetype. %f = the file, %o = a temporary binary.
local runners = {
	c = "cc -Wall -Wextra -Werror -g %f -o %o && %o",
	cpp = "c++ -Wall -Wextra -Werror -std=c++17 -g %f -o %o && %o",
	python = "python3 %f",
	lua = "nvim -l %f",
	sh = "bash %f",
	bash = "bash %f",
	zsh = "zsh %f",
	fish = "fish %f",
	javascript = "node %f",
	typescript = "npx --yes tsx %f",
	go = "go run %f",
	rust = "rustc %f -o %o && %o",
	java = "java %f",
	make = "make",
}

local function terminal()
	if not M.term then
		M.term = require("toggleterm.terminal").Terminal:new({
			direction = "horizontal",
			display_name = "run",
			close_on_exit = false,
		})
	end
	if not M.term:is_open() then
		M.term:open()
	end
	return M.term
end

function M.send(cmd)
	last = cmd
	vim.cmd("silent! wall")
	local term = terminal()
	term:send("clear; " .. cmd, true) -- true: keep focus in the code
end

function M.file()
	local file = vim.fn.expand("%:p")
	local runner = runners[vim.bo.filetype]
	if not runner or file == "" then
		-- No recipe for this kind of file: a Makefile nearby is the next best guess.
		if vim.fn.filereadable("Makefile") == 1 then
			return M.make()
		end
		return vim.notify("Don't know how to run " .. vim.bo.filetype .. " files; try Space r c",
			vim.log.levels.WARN)
	end
	local out = vim.fn.tempname()
	local cmd = runner:gsub("%%f", vim.fn.shellescape(file)):gsub("%%o", vim.fn.shellescape(out))
	M.send(cmd)
end

function M.make()
	M.send("make")
end

function M.prompt()
	vim.ui.input({ prompt = "Run: ", default = last }, function(cmd)
		if cmd and cmd ~= "" then
			M.send(cmd)
		end
	end)
end

function M.again()
	if last then
		M.send(last)
	else
		M.file()
	end
end

return M
