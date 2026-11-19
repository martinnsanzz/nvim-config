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

-- Autosave like VS Code's "afterDelay": save 1 second after you stop typing,
-- and right away when you switch files or leave nvim
local autosave_delay = 1000
local timers = {}

local function autosave(buf)
	if not vim.api.nvim_buf_is_valid(buf) then return end
	local bo = vim.bo[buf]
	if not bo.modified or bo.buftype ~= "" or not bo.modifiable or bo.readonly then return end
	local name = vim.api.nvim_buf_get_name(buf)
	if name == "" or vim.fn.isdirectory(vim.fn.fnamemodify(name, ":h")) == 0 then return end
	vim.api.nvim_buf_call(buf, function() vim.cmd("silent! lockmarks update") end)
end

autocmd({ "TextChanged", "TextChangedI" }, {
	group = group,
	callback = function(args)
		local timer = timers[args.buf] or vim.uv.new_timer()
		timers[args.buf] = timer
		timer:stop()
		timer:start(autosave_delay, 0, vim.schedule_wrap(function() autosave(args.buf) end))
	end,
})

autocmd({ "BufLeave", "FocusLost" }, {
	group = group,
	callback = function(args) autosave(args.buf) end,
})

autocmd("BufDelete", {
	group = group,
	callback = function(args)
		local timer = timers[args.buf]
		if timer then
			timer:stop()
			timer:close()
			timers[args.buf] = nil
		end
	end,
})

-- q closes help, quickfix and other read-only panels
autocmd("FileType", {
	group = group,
	pattern = { "help", "qf", "man", "checkhealth", "lspinfo", "notify", "dap-float" },
	callback = function(args)
		vim.bo[args.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf, silent = true })
	end,
})
