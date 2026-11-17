-- Neovim set up like VS Code: file tree, tabs, search, LSP, completion,
-- run/debug and git, in the green "phosphor" style of Danitell0/nvim-config.
-- Every shortcut is listed in keys.txt (Space ? inside nvim, Option+n in tmux).

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")

vim.g.phosphor_transparent = true -- let Ghostty's see-through background show
vim.cmd.colorscheme("phosphor")
