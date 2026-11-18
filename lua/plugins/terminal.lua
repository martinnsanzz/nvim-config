-- Terminals inside nvim (VS Code's bottom panel). Ctrl+\ toggles the last one.
return {
	"akinsho/toggleterm.nvim",
	version = "*",
	cmd = { "ToggleTerm", "TermExec" },
	keys = {
		{ [[<C-\>]], desc = "Terminal (toggle)" },
		{ "<leader>tt", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Terminal at the bottom" },
		{ "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", desc = "Floating terminal" },
		{ "<leader>tv", "<cmd>ToggleTerm direction=vertical size=70<CR>", desc = "Terminal on the right" },
	},
	opts = {
		open_mapping = [[<C-\>]],
		autochdir = true, -- follow nvim into another project (Space p)
		size = function(term)
			return term.direction == "vertical" and 70 or 20
		end,
		shade_terminals = false,
		start_in_insert = true,
		persist_mode = false,
		float_opts = { border = "rounded" },
		-- A bottom terminal opens under every window, tree included. Push the tree
		-- back to the far right at full height so the terminal only spans the code.
		on_open = function(term)
			if term.direction ~= "horizontal" then
				return
			end
			for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
				if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
					local width = vim.api.nvim_win_get_width(win)
					local height = vim.api.nvim_win_get_height(term.window)
					vim.api.nvim_win_call(win, function() vim.cmd("wincmd L") end)
					vim.api.nvim_win_set_width(win, width)
					vim.api.nvim_win_set_height(term.window, height)
					return
				end
			end
		end,
	},
	init = function()
		-- Closing the last code window would leave the terminal filling the left
		-- side. Put an empty editor back above it instead.
		vim.api.nvim_create_autocmd("WinClosed", {
			group = vim.api.nvim_create_augroup("keep-editor", { clear = true }),
			callback = function()
				vim.schedule(function()
					local term
					for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
						local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
						if vim.api.nvim_win_get_config(win).relative ~= "" then
							-- floating windows (popups, float terminal) don't count
						elseif ft == "toggleterm" then
							term = win
						elseif ft ~= "neo-tree" then
							return -- an editor window is still there
						end
					end
					if term then
						local editor
						vim.api.nvim_win_call(term, function()
							vim.cmd("aboveleft new")
							editor = vim.api.nvim_get_current_win()
						end)
						local size = require("toggleterm.config").get("size")
						vim.api.nvim_win_set_height(term, type(size) == "function" and size({ direction = "horizontal" }) or size)
						vim.api.nvim_set_current_win(editor)
						vim.cmd("stopinsert")
					end
				end)
			end,
		})

		-- In a terminal: Esc or Ctrl+j to scroll/copy, Ctrl+x to hide it
		vim.api.nvim_create_autocmd("TermOpen", {
			pattern = "term://*toggleterm#*",
			callback = function(args)
				local o = { buffer = args.buf }
				vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], o)
				vim.keymap.set("t", "<C-x>", [[<C-\><C-n><cmd>ToggleTerm<CR>]], o)
				vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], o)
				vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], o)
			end,
		})
	end,
}
