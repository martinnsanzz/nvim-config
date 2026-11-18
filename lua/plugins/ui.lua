-- How nvim looks: start screen, tabs bar, status line, popups, key hints.
local header = [[
░▒▓ ─────────────────────────────────────────────────────── ▓▒░

  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝

▓▒░ ﾊﾋﾌ ════════════════ [ SYSTEM ONLINE ] ════════════════ ｦｧｨ ░▒▓]]

return {
	{ "nvim-tree/nvim-web-devicons", lazy = true },

	-- VS Code's Dark+ colors (set in init.lua)
	{
		"Mofiqul/vscode.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "dark",
			transparent = false, -- true lets Ghostty's see-through background show
			italic_comments = true,
		},
	},

	-- Start screen, plus small helpers (closing tabs, lazygit, inputs)
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = { enabled = true },
			input = { enabled = true },
			lazygit = { enabled = true },
			dashboard = {
				enabled = true,
				width = 66,
				preset = {
					header = header,
					keys = {
						{ icon = " ", key = "f", desc = "Find file", action = ":Telescope find_files" },
						{ icon = "\u{f07c} ", key = "p", desc = "Open project", action = function() require("config.projects").pick() end },
						{ icon = "󰍉 ", key = "g", desc = "Find word in project", action = ":Telescope live_grep" },
						{ icon = " ", key = "r", desc = "Recent files", action = ":Telescope oldfiles" },
						{ icon = " ", key = "n", desc = "New file", action = ":ene | startinsert" },
						{ icon = " ", key = "s", desc = "Shortcuts", action = function() require("config.cheatsheet").open() end },
						{ icon = " ", key = "c", desc = "Config", action = ":Telescope find_files cwd=~/.config/nvim" },
						{ icon = "󰒲 ", key = "l", desc = "Plugins", action = ":Lazy" },
						{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
					},
				},
				sections = {
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 2 },
					{ text = { "(ノಠ益ಠ)ノ彡┻━┻", hl = "SnacksDashboardFooter" }, align = "center" },
				},
			},
		},
	},

	-- Open files as tabs along the top, like VS Code
	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				mode = "buffers",
				separator_style = "thin",
				diagnostics = "nvim_lsp",
				show_buffer_close_icons = true, -- click the x to close, like VS Code
				close_command = function(n) Snacks.bufdelete(n) end,
				offsets = { { filetype = "neo-tree", text = "EXPLORER", text_align = "left", separator = true } },
			},
		},
	},

	-- Status line at the bottom
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = "vscode",
				globalstatus = true,
				component_separators = "│",
				section_separators = "",
				disabled_filetypes = { statusline = { "snacks_dashboard" } },
			},
			sections = {
				lualine_a = {
					"mode",
					{
						function() return " recording to " .. vim.fn.reg_recording() end,
						color = "DiagnosticError",
						cond = function() return vim.fn.reg_recording() ~= "" end,
					},
				},
				lualine_b = { "branch", "diff" },
				lualine_c = { { "filename", path = 1 }, "diagnostics" },
				lualine_x = { "lsp_status", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		},
	},

	-- Messages, the : command line and LSP docs in nice popups
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		opts = {
			lsp = {
				progress = { enabled = false },
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			routes = {
				-- "written", "x lines yanked" and similar go to a corner popup
				{
					filter = { event = "msg_show", ["not"] = { kind = { "search_count" } } },
					view = "notify",
					opts = { level = "info", skip = false, replace = true },
				},
			},
			presets = {
				long_message_to_split = true,
				lsp_doc_border = true,
			},
		},
		keys = {
			{ "<leader>nd", "<cmd>NoiceDismiss<CR>", desc = "Dismiss messages" },
			{ "<leader>nh", "<cmd>NoiceHistory<CR>", desc = "Message history" },
		},
	},
	{ "rcarriga/nvim-notify", lazy = true, opts = { stages = "fade" } },

	-- Pops up the possible next keys after you press Space (or g, [, ...)
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",
			spec = {
				{ "<leader>b", group = "tabs" },
				{ "<leader>c", group = "code" },
				{ "<leader>d", group = "debug" },
				{ "<leader>f", group = "find" },
				{ "<leader>g", group = "git" },
				{ "<leader>n", group = "messages" },
				{ "<leader>p", desc = "Switch project" },
				{ "<leader>r", group = "run" },
				{ "<leader>t", group = "terminal" },
				{ "<leader>x", group = "problems" },
				{ "<leader>1", hidden = true }, { "<leader>2", hidden = true }, { "<leader>3", hidden = true },
				{ "<leader>4", hidden = true }, { "<leader>5", hidden = true }, { "<leader>6", hidden = true },
				{ "<leader>7", hidden = true }, { "<leader>8", hidden = true }, { "<leader>9", hidden = true },
			},
		},
	},

	-- Indent guides, and a fading line at the column limit
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			indent = { char = "│" },
			scope = { show_start = false, show_end = false },
			exclude = { filetypes = { "snacks_dashboard", "neo-tree", "help", "lazy", "mason" } },
		},
	},
	{ "Bekaboo/deadcolumn.nvim", event = { "BufReadPost", "BufNewFile" } },

	-- Rendered markdown headings, lists and code blocks
	{ "OXY2DEV/markview.nvim", ft = "markdown" },
}
