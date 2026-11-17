# nvim-config

My Neovim, set up to work like VS Code: a file tree, tabs for open files, fuzzy search, errors as you type, autocomplete, run and debug buttons, and git. The look (green `phosphor` theme, start screen, tabs bar, popups) comes from [Danitell0/nvim-config](https://github.com/Danitell0/nvim-config).

Every shortcut is in [`keys.txt`](keys.txt). Open it with `Space ?` inside nvim, or `Option+n` anywhere in my [dotfiles](../dotfiles) tmux setup. Press `Space` and wait to see what can follow.

## Install

Needs Neovim 0.12+, git, a C compiler, `make`, node/npm, plus a few CLI tools:

```sh
brew install neovim ripgrep fd lazygit tree-sitter-cli
git clone <this repo> ~/Projects/Claude/nvim-config
ln -s ~/Projects/Claude/nvim-config ~/.config/nvim
nvim   # first start downloads the plugins; then run :MasonToolsInstallSync
```

My dotfiles' `install.sh` does the link (and clones this repo if it's missing).

## What's where

| File | What it does |
|---|---|
| `init.lua` | Loads everything below and picks the color scheme. |
| `lua/config/options.lua` | Editor settings: line numbers, tabs (4-wide real tabs, Codam norm), clipboard, search. |
| `lua/config/keymaps.lua` | Shortcuts that aren't tied to a plugin (save, comment, splits, tabs, run). |
| `lua/config/autocmds.lua` | Small automatic things, plus extra `phosphor` colors for plugins it didn't cover. |
| `lua/config/run.lua` | The run button: `F5` compiles and runs the current file in a bottom terminal. |
| `lua/config/header42.lua` | The Codam/42 header (`Space c h`), refreshed on save. Uses `$USER42` and `$MAIL42`. |
| `lua/config/cheatsheet.lua` | Shows `keys.txt` in a popup. |
| `lua/plugins/ui.lua` | Start screen, tabs bar, status line, popups, which-key, indent guides, cursor trail. |
| `lua/plugins/editor.lua` | File tree, telescope search, bookmarks, clipboard history, git signs, problems panel. |
| `lua/plugins/lsp.lua` | Language servers (Mason), autocomplete, formatting. |
| `lua/plugins/treesitter.lua` | Syntax highlighting. |
| `lua/plugins/debug.lua` | Debugger (codelldb for C/C++, debugpy for Python). |
| `lua/plugins/terminal.lua` | Terminals inside nvim. |
| `after/ftplugin/*.lua` | Per-language indentation. |
| `colors/phosphor.lua` | The color scheme, copied unchanged from Danitell0/nvim-config. |
| `lazy-lock.json` | Exact plugin versions. `:Lazy update` updates them; commit the new file. |

## Languages

C/C++ (clangd), Python (basedpyright, ruff), Lua, Bash, JavaScript/TypeScript and JSON are set up. Add a language with `:Mason` (`i` installs), and put it in the `servers` or `tools` list in `lua/plugins/lsp.lua` so a fresh install gets it too. For the run button, add a line to `runners` in `lua/config/run.lua`.

Formatting is never automatic (clang-format doesn't follow the Codam norm). `Space c f` formats when you want it.
