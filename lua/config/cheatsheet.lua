-- Space ? : keys.txt (the same list as Option+n in tmux) in a floating window.
local M = {}

function M.open()
	local path = vim.fn.stdpath("config") .. "/keys.txt"
	local lines = vim.fn.readfile(path)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "nvimkeys"

	local width = math.min(84, vim.o.columns - 4)
	local height = math.min(#lines, vim.o.lines - 4)
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2) - 1,
		col = math.floor((vim.o.columns - width) / 2),
		border = "rounded",
		title = " nvim shortcuts · / search · q close ",
		title_pos = "center",
	})
	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", key, "<cmd>close<CR>", { buffer = buf, silent = true })
	end
	-- Section titles in caps stand out
	vim.fn.matchadd("Title", [[^ [A-Z][A-Z /&()+-]\+$]])
	vim.fn.matchadd("Special", [[^ \{3}\S\+\( \S\+\)\{-}\ze \{2,}]])
end

return M
