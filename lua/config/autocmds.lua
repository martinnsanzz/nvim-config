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
