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
		size = function(term)
			return term.direction == "vertical" and 70 or 14
		end,
		shade_terminals = false,
		start_in_insert = true,
		persist_mode = false,
		float_opts = { border = "rounded" },
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
