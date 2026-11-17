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
						{ icon = " ", key = "e", desc = "File tree", action = ":Neotree reveal" },
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
				show_buffer_close_icons = false,
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
				theme = "auto",
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
	{ "rcarriga/nvim-notify", lazy = true, opts = { background_colour = "#000000", stages = "fade" } },

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
				{ "<leader>r", group = "run" },
				{ "<leader>t", group = "terminal" },
				{ "<leader>u", group = "look" },
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

	-- The cursor leaves a short trail when it jumps
	{
		"sphamba/smear-cursor.nvim",
		event = "VeryLazy",
		opts = {
			smear_between_buffers = true,
			smear_between_neighbor_lines = true,
			scroll_buffer_space = true,
			stiffness = 0.8,
			trailing_stiffness = 0.6,
			stiffness_insert_mode = 0.7,
			trailing_stiffness_insert_mode = 0.7,
			damping = 0.95,
			damping_insert_mode = 0.95,
			distance_stop_animating = 0.5,
			time_interval = 7,
			transparent_bg_fallback_color = "#303030",
		},
	},

	-- Rendered markdown headings, lists and code blocks
	{ "OXY2DEV/markview.nvim", ft = "markdown" },

	-- Other color schemes to try with Space u c (the choice isn't saved;
	-- change init.lua to keep one)
	{ "navarasu/onedark.nvim", lazy = true },
	{ "folke/tokyonight.nvim", lazy = true },
	{ "catppuccin/nvim", name = "catppuccin", lazy = true },
	{ "rebelot/kanagawa.nvim", lazy = true },
	{ "ribru17/bamboo.nvim", lazy = true },
}
