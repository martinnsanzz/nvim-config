-- Neovim set up like VS Code: pick a project on start, file tree, tabs,
-- search, LSP, completion, run/debug and git, in VS Code's Dark+ colors.
-- Every shortcut is listed in keys.txt (Space ? inside nvim, Option+n in tmux).

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")

vim.cmd.colorscheme("vscode")
