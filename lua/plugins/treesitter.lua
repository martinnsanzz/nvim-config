-- Syntax highlighting that understands the code (and smarter indenting).
-- Parsers are compiled with the tree-sitter CLI (brew install tree-sitter-cli).
local languages = {
	"c", "cpp", "make", "lua", "python", "bash", "fish", "javascript", "typescript", "tsx",
	"json", "yaml", "toml", "html", "css", "markdown", "markdown_inline", "vim", "vimdoc",
	"query", "regex", "diff", "gitcommit",
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install(languages)
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter", { clear = true }),
			callback = function(args)
				-- Only for languages with a parser; others keep regular syntax.
				if pcall(vim.treesitter.start, args.buf) then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
