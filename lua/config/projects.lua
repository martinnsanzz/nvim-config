-- Project picker (VS Code's "Open Folder"): `nvim` with no file asks which
-- project to open, Space p switches. Picking one moves into its folder,
-- reopens the files you had open there last time, and shows the file tree.
local M = {}

-- Every folder inside these with a .git or Makefile is a project
M.dirs = { "~/Projects/Claude", "~/Projects/Codam-Projects" }

-- Are any real files open?
local function has_files()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
			return true
		end
	end
	return false
end

function M.open(dir)
	dir = vim.fs.normalize(dir)
	if vim.fn.getcwd() == dir then
		return vim.cmd("Neotree focus")
	end
	vim.cmd("silent! Neotree close")
	-- Remember the project we're leaving, then start clean in the new one
	if has_files() then
		vim.cmd("silent! wall")
		require("persistence").save()
		vim.cmd("silent! %bwipeout")
	end
	vim.fn.chdir(dir)
	require("persistence").load()
	M.panels()
	-- No files came back: put the cursor in the tree to pick one
	if not has_files() then
		vim.cmd("Neotree focus")
	end
end

-- Show the file tree (right) and a terminal (bottom), keeping the cursor in the code
function M.panels()
	local win = vim.api.nvim_get_current_win()
	vim.cmd("Neotree show")
	local has_term = false
	for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "toggleterm" then
			has_term = true
		end
	end
	if not has_term then
		vim.cmd("ToggleTerm direction=horizontal")
	end
	if vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_set_current_win(win)
	end
	vim.cmd("stopinsert")
end

function M.pick()
	Snacks.picker.projects({
		title = "Open project",
		dev = M.dirs,
		confirm = function(picker, item)
			picker:close()
			if item then
				M.open(item.file)
			end
		end,
	})
end

return M
