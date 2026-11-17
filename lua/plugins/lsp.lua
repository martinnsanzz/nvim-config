-- Language smarts: errors as you type, go to definition, rename, autocomplete,
-- formatting. Mason downloads the language servers and tools listed here.
local servers = { "clangd", "lua_ls", "basedpyright", "bashls", "ts_ls", "jsonls" }
local tools = { "clang-format", "stylua", "ruff", "prettier", "shfmt", "codelldb", "debugpy" }

return {
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<CR>", desc = "Install languages (Mason)" } },
		opts = {
			ui = {
				border = "rounded",
				icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
			},
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		dependencies = { "mason-org/mason.nvim" },
		-- Servers too, so :MasonToolsInstallSync sets up everything at once
		opts = { ensure_installed = vim.list_extend(vim.deepcopy(servers), tools) },
	},

	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			-- Installs the servers above and turns them on
			{ "mason-org/mason-lspconfig.nvim", opts = { ensure_installed = servers } },
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })
			vim.lsp.config("lua_ls", {
				settings = { Lua = { workspace = { checkThirdParty = false }, telemetry = { enable = false } } },
			})
			vim.lsp.config("basedpyright", {
				settings = {
					basedpyright = { analysis = { typeCheckingMode = "standard", diagnosticMode = "openFilesOnly" } },
				},
			})

			-- nvim's own gr* shortcuts would make gr (references) wait for a
			-- second key; drop them so gr answers straight away.
			for _, lhs in ipairs({ "grr", "gra", "grn", "gri", "grt", "grx" }) do
				pcall(vim.keymap.del, { "n", "x" }, lhs)
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-keys", { clear = true }),
				callback = function(args)
					local function map(lhs, rhs, desc, mode)
						vim.keymap.set(mode or "n", lhs, rhs, { buffer = args.buf, desc = desc })
					end
					local tb = require("telescope.builtin")
					map("gd", tb.lsp_definitions, "Go to definition")
					map("<F12>", tb.lsp_definitions, "Go to definition")
					map("gD", vim.lsp.buf.declaration, "Go to declaration")
					map("gr", tb.lsp_references, "Find all references")
					map("gi", tb.lsp_implementations, "Go to implementation")
					map("gt", tb.lsp_type_definitions, "Go to type")
					map("K", function() vim.lsp.buf.hover({ border = "rounded" }) end, "Show docs")
					map("<C-k>", vim.lsp.buf.signature_help, "Show function arguments", "i")
					map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
					map("<F2>", vim.lsp.buf.rename, "Rename symbol")
					map("<leader>ca", vim.lsp.buf.code_action, "Quick fix / code action", { "n", "v" })
					map("<leader>fs", tb.lsp_document_symbols, "Find function in this file")
					map("<leader>fS", tb.lsp_dynamic_workspace_symbols, "Find function in project")
					map("<leader>ci", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }),
							{ bufnr = args.buf })
					end, "Toggle inline type hints")
					-- C/C++: jump between foo.c and foo.h
					if vim.lsp.get_client_by_id(args.data.client_id).name == "clangd" then
						map("<leader>co", "<cmd>LspClangdSwitchSourceHeader<CR>", "Switch .c ⇄ .h")
					end
				end,
			})
		end,
	},

	-- Lua: knows nvim's own API (for editing this config)
	{ "folke/lazydev.nvim", ft = "lua", opts = {} },

	-- Autocomplete popup
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			{ "L3MON4D3/LuaSnip", version = "v2.*", dependencies = { "rafamadriz/friendly-snippets" } },
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				-- VS Code style: Tab / Shift+Tab move through the list (and the
				-- blanks of a snippet), Enter accepts.
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.locally_jumpable(1) then
							luasnip.jump(1)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "lazydev", group_index = 0 },
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				}, {
					{ name = "buffer" },
				}),
			})
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
			})
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = { { name = "buffer" } },
			})
			-- Accepting a function adds the ( ) too
			cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
		end,
	},

	-- Formatting (Space c f). Not on save: clang-format doesn't follow the
	-- Codam norm, so you choose when to run it.
	{
		"stevearc/conform.nvim",
		cmd = "ConformInfo",
		keys = {
			{ "<leader>cf", function() require("conform").format({ lsp_format = "fallback" }) end,
				mode = { "n", "v" }, desc = "Format file / selection" },
		},
		opts = {
			formatters_by_ft = {
				c = { "clang-format" },
				cpp = { "clang-format" },
				lua = { "stylua" },
				python = { "ruff_format" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				json = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				markdown = { "prettier" },
				sh = { "shfmt" },
				bash = { "shfmt" },
			},
		},
	},
}
