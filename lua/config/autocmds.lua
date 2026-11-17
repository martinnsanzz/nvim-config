local autocmd = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("config", { clear = true })

-- Flash what you just copied
autocmd("TextYankPost", {
	group = group,
	callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- Reopen a file where you left off
autocmd("BufReadPost", {
	group = group,
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Pick up changes made outside nvim (git, claude in another pane)
autocmd({ "FocusGained", "BufEnter" }, { group = group, command = "silent! checktime" })

-- q closes help, quickfix and other read-only panels
autocmd("FileType", {
	group = group,
	pattern = { "help", "qf", "man", "checkhealth", "lspinfo", "notify", "dap-float" },
	callback = function(args)
		vim.bo[args.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf, silent = true })
	end,
})

-- phosphor only colors the plugins Danitell0 used; give the rest green too.
autocmd("ColorScheme", {
	group = group,
	pattern = "phosphor",
	callback = function()
		local set = vim.api.nvim_set_hl
		set(0, "NeoTreeNormal", { link = "Normal" })
		set(0, "NeoTreeNormalNC", { link = "Normal" })
		set(0, "NeoTreeDirectoryName", { fg = "#00ffc8" })
		set(0, "NeoTreeDirectoryIcon", { fg = "#00ffc8" })
		set(0, "NeoTreeRootName", { fg = "#a8ff3e", bold = true })
		set(0, "NeoTreeGitModified", { fg = "#ffcc44" })
		set(0, "NeoTreeGitUntracked", { fg = "#a8ff3e" })
		set(0, "NeoTreeWinSeparator", { fg = "#1c3a24" })
		set(0, "GitSignsAdd", { fg = "#46d97a" })
		set(0, "GitSignsChange", { fg = "#ffcc44" })
		set(0, "GitSignsDelete", { fg = "#ff5555" })
		set(0, "SnacksDashboardHeader", { fg = "#46d97a" })
		set(0, "SnacksDashboardIcon", { fg = "#00ffc8" })
		set(0, "SnacksDashboardDesc", { fg = "#46d97a" })
		set(0, "SnacksDashboardKey", { fg = "#a8ff3e", bold = true })
		set(0, "SnacksDashboardFooter", { fg = "#1f6b33", italic = true })
		set(0, "IblIndent", { fg = "#0e1f12" })
		set(0, "IblScope", { fg = "#1f6b33" })
		set(0, "DapBreakpoint", { fg = "#ff5555" })
		set(0, "DapStopped", { fg = "#a8ff3e" })
	end,
})
