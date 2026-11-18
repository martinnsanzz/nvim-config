-- Getting around: projects, file tree, search, git.
return {
	-- File tree on the right (VS Code's explorer)
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
			-- Look like VS Code's explorer
			default_component_configs = {
				indent = { with_markers = true, indent_marker = "│", last_indent_marker = "└" },
				git_status = {
					-- Letters after the name, like VS Code
					symbols = { added = "A", modified = "M", deleted = "D", renamed = "R", untracked = "U" },
				},
			},
			window = {
				position = "right",   -- "left" (default), "right", "top", "bottom" or "float"
				width = 30,
				mappings = {
					["l"] = "open",
					["h"] = "close_node",
					["<space>"] = "none", -- leave Space as the leader key
				},
			},
			filesystem = {
				hijack_netrw_behavior = "open_default", -- `nvim .` opens the tree in its usual place (right)
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
				filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = false },
			},
		},
	},

	-- Projects: each folder remembers its open files (lua/config/projects.lua)
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {},
		keys = { { "<leader>p", function() require("config.projects").pick() end, desc = "Switch project" } },
		init = function()
			local group = vim.api.nvim_create_augroup("projects", { clear = true })
			-- The tree would come back as an empty window; leave it out of the session
			vim.api.nvim_create_autocmd("User", {
				group = group,
				pattern = "PersistenceSavePre",
				command = "silent! Neotree close",
			})
			-- `nvim` on its own asks for a project; `nvim file` / `nvim .` skip the
			-- picker and open the file tree (right) and a terminal (bottom) straight away
			vim.api.nvim_create_autocmd("VimEnter", {
				group = group,
				callback = function()
					local projects = require("config.projects")
					vim.schedule(vim.fn.argc() == 0 and projects.pick or projects.panels)
				end,
			})
		end,
	},

	-- Fuzzy finder for files, words, recent files, symbols...
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-ui-select.nvim",
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
			})
			pcall(telescope.load_extension, "fzf")
			telescope.load_extension("ui-select")
			pcall(telescope.load_extension, "noice")
		end,
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
