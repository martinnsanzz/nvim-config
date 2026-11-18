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
