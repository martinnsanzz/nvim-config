local opt = vim.opt

vim.g.mapleader = " " -- Space starts most shortcuts
vim.g.maplocalleader = " "

-- Line numbers: absolute on the cursor line, relative elsewhere (for 5j etc.)
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes" -- room for git and error marks, so text doesn't jump

-- Tabs: 4 wide, real tab characters (Codam's norm); ftplugins change this
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = false
opt.smartindent = true

-- Behave like a normal editor
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- y and p use the macOS clipboard
opt.undofile = true -- undo survives closing the file
opt.swapfile = false
opt.confirm = true -- ask to save instead of refusing to quit
opt.updatetime = 250
opt.timeoutlen = 400 -- how long which-key waits before showing hints

-- Search: case-insensitive unless you type a capital
opt.ignorecase = true
opt.smartcase = true

-- Look
opt.termguicolors = true
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.showmode = false -- lualine shows the mode
opt.laststatus = 3 -- one status line for the whole window, like VS Code
opt.list = true
opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " " } -- no ~ after the end of the file

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

vim.diagnostic.config({
	virtual_text = { spacing = 2, prefix = "●" }, -- the error at the end of the line
	underline = true,
	severity_sort = true,
	float = { border = "rounded", source = true },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = "󰌵 ",
		},
	},
})
