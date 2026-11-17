-- Getting around: file tree, search, bookmarks, clipboard history, git.
return {
	-- File tree on the left (VS Code's explorer)
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle reveal<CR>", desc = "File tree (toggle)" },
			{ "<leader>E", "<cmd>Neotree focus reveal<CR>", desc = "File tree (focus)" },
			{ "<leader>ge", "<cmd>Neotree float git_status<CR>", desc = "Changed files" },
		},
		-- `nvim .` or `nvim some/folder` opens the tree instead of a blank page
		init = function()
			vim.api.nvim_create_autocmd("BufEnter", {
				group = vim.api.nvim_create_augroup("neotree-start", { clear = true }),
				callback = function()
					if vim.fn.isdirectory(vim.fn.expand("%")) == 1 then
						require("neo-tree")
						return true
					end
				end,
			})
		end,
		opts = {
			close_if_last_window = true,
			popup_border_style = "rounded",
			window = {
				width = 32,
				mappings = {
					["l"] = "open",
					["h"] = "close_node",
					["<space>"] = "none", -- leave Space as the leader key
				},
			},
			filesystem = {
				hijack_netrw_behavior = "open_current",
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
				filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = false },
			},
		},
	},

	-- Fuzzy finder for files, words, recent files, symbols...
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-ui-select.nvim",
			"andrew-george/telescope-themes",
		},
		keys = {
			{ "<C-p>", "<cmd>Telescope find_files<CR>", desc = "Find file" },
			{ "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find file" },
			{ "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Find word in project" },
			{ "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Find word under cursor" },
			{ "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Find in this file" },
			{ "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Open tabs" },
			{ "<leader>fo", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
			{ "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help pages" },
			{ "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Search shortcuts" },
			{ "<leader>fc", "<cmd>Telescope commands<CR>", desc = "Commands (like Cmd+Shift+P)" },
			{ "<leader>fr", "<cmd>Telescope resume<CR>", desc = "Reopen last search" },
			{ "<leader>xd", "<cmd>Telescope diagnostics<CR>", desc = "Search all errors" },
			{ "<leader>uc", "<cmd>Telescope themes<CR>", desc = "Color scheme" },
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			telescope.setup({
				defaults = {
					prompt_prefix = "   ",
					selection_caret = " -> ",
					entry_prefix = " ",
					sorting_strategy = "ascending",
					layout_config = {
						horizontal = { prompt_position = "bottom", preview_width = 0.65 },
						width = 0.87,
						height = 0.80,
					},
					file_ignore_patterns = { "%.git/", "node_modules/", "%.o$" },
					mappings = {
						n = { ["q"] = actions.close, ["<C-q>"] = actions.close },
						i = {
							["<C-q>"] = actions.close,
							["<C-u>"] = false,
							["<C-j>"] = actions.move_selection_next,
							["<C-k>"] = actions.move_selection_previous,
						},
					},
				},
				pickers = {
					find_files = { hidden = true },
				},
				extensions = {
					themes = {
						enable_previewer = false,
						enable_live_preview = true,
						persist = { enabled = false },
						light_themes = { ignore = true },
					},
				},
			})
			pcall(telescope.load_extension, "fzf")
			telescope.load_extension("ui-select")
			telescope.load_extension("themes")
			pcall(telescope.load_extension, "neoclip")
			pcall(telescope.load_extension, "noice")
		end,
	},

	-- Bookmark up to a handful of files and jump between them
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>a", function() require("harpoon"):list():add() end, desc = "Bookmark this file" },
			{ "<C-e>", function() local h = require("harpoon") h.ui:toggle_quick_menu(h:list()) end,
				desc = "Bookmarked files" },
			{ "<leader>fl", function() local h = require("harpoon") h.ui:toggle_quick_menu(h:list()) end,
				desc = "Bookmarked files" },
			{ "]b", function() require("harpoon"):list():next() end, desc = "Next bookmark" },
			{ "[b", function() require("harpoon"):list():prev() end, desc = "Previous bookmark" },
		},
		config = function() require("harpoon"):setup() end,
	},

	-- Everything you've copied, searchable
	{
		"AckslD/nvim-neoclip.lua",
		event = "VeryLazy",
		dependencies = { "nvim-telescope/telescope.nvim" },
		keys = { { "<leader>fy", "<cmd>Telescope neoclip<CR>", desc = "Clipboard history" } },
		opts = {},
	},

	-- Close brackets and quotes as you type
	{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

	-- Git: changed lines in the margin, blame, and lazygit
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			on_attach = function(buf)
				local gs = require("gitsigns")
				local function map(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc }) end
				map("]h", function() gs.nav_hunk("next") end, "Next change")
				map("[h", function() gs.nav_hunk("prev") end, "Previous change")
				map("<leader>gp", gs.preview_hunk, "Preview change")
				map("<leader>gs", gs.stage_hunk, "Stage change")
				map("<leader>gr", gs.reset_hunk, "Undo change")
				map("<leader>gb", function() gs.blame_line({ full = true }) end, "Who wrote this line")
				map("<leader>gd", gs.diffthis, "Diff this file")
			end,
		},
	},
	{
		"folke/snacks.nvim",
		keys = { { "<leader>gg", function() Snacks.lazygit() end, desc = "lazygit" } },
	},

	-- Problems panel (VS Code's Problems tab)
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Problems (whole project)" },
			{ "<leader>xf", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Problems (this file)" },
			{ "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Outline (functions…)" },
			{ "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "TODOs" },
		},
	},
	{ "folke/todo-comments.nvim", event = { "BufReadPost", "BufNewFile" }, opts = {} },
}
