# nvim-config

My Neovim, set up to work like VS Code. Run `nvim`, pick a project, and you get a VS Code style layout: open files as tabs along the top, the file tree on the right and a terminal at the bottom. It also has fuzzy search, errors as you type, autocomplete, run and debug, and git. Colors are VS Code's Dark+ ([vscode.nvim](https://github.com/Mofiqul/vscode.nvim)). The start screen, tabs bar and popups are based on [Danitell0/nvim-config](https://github.com/Danitell0/nvim-config).

> **Made with Claude.** This configuration was written by [Claude](https://claude.com/claude-code) (Anthropic's AI assistant, through Claude Code), working with me as I learned Neovim. I described what I wanted; Claude wrote the Lua, explained it, and tested it.

## Layout

```
┌──────────────── tabs (open files) ────────────────┬──────────┐
│                                                   │ EXPLORER │
│                    code                           │  (tree)  │
│                                                   │          │
├───────────────────────────────────────────────────┤          │
│                    terminal                       │          │
└───────────────────────────────────────────────────┴──────────┘
```

The tree and the terminal open by themselves on every start:

| You run | What happens |
|---|---|
| `nvim` | A project picker. Picking one reopens the files you had open there, then shows the tree and the terminal. |
| `nvim some/file` | Opens that file with the tree and the terminal, without the picker. |
| `nvim .` | Opens the tree and the terminal next to an empty editor. |

`Space e` hides or shows the tree. `Ctrl+\` hides or shows the terminal.

## Projects

The picker lists every folder in `~/Projects/Claude` and `~/Projects/Codam-Projects` that has a `.git` or `Makefile`. Change the list in `lua/config/projects.lua`. Each project remembers its open files ([persistence.nvim](https://github.com/folke/persistence.nvim)), and the terminal follows you into the project's folder. `Space p` switches project.

## Shortcuts

Every shortcut is in [`keys.txt`](keys.txt). Open it with `Space ?` inside nvim. Press `Space` and wait to see what can follow. The most used ones:

| Key | Does |
|---|---|
| `Ctrl+s` | Save |
| `Ctrl+p` / `Space f g` | Find a file / find a word in the project |
| `Tab` / `Shift+Tab` | Next / previous open file |
| `Space w` | Close the current file |
| `Ctrl+h/j/k/l` | Move between windows (code, tree, terminal) |
| `Esc` or `Ctrl+j` (in a terminal) | Leave terminal typing mode |
| `F5` | Run the current file |
| `gl` | Show the error under the cursor |

## Install

You need Neovim 0.12 or newer, git, a C compiler, `make`, node/npm, and a few CLI tools:

```sh
brew install neovim ripgrep fd lazygit tree-sitter-cli
git clone https://github.com/martinnsanzz/nvim-config.git ~/Projects/Claude/nvim-config
ln -s ~/Projects/Claude/nvim-config ~/.config/nvim
nvim   # first start downloads the plugins; then run :MasonToolsInstallSync
```

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim). `lazy-lock.json` pins their exact versions.

## What's where

| File | What it does |
|---|---|
| `init.lua` | Loads everything below and picks the color scheme. |
| `lua/config/options.lua` | Editor settings: line numbers, tabs (4-wide real tabs, Codam norm), clipboard, search. |
| `lua/config/keymaps.lua` | Shortcuts that aren't tied to a plugin (save, comment, splits, tabs, run). |
| `lua/config/autocmds.lua` | Small automatic things (autosave, flash on copy, reopen at last position, reload changed files). |
| `lua/config/lazy.lua` | Installs and loads the plugin manager. |
| `lua/config/projects.lua` | The project picker, and opening the tree and terminal on start. |
| `lua/config/run.lua` | The run button: `F5` compiles and runs the current file in a bottom terminal. |
| `lua/config/cheatsheet.lua` | Shows `keys.txt` in a popup. |
| `lua/plugins/ui.lua` | Color scheme, start screen, tabs bar, status line, popups, which-key, indent guides. |
| `lua/plugins/editor.lua` | File tree (neo-tree, on the right), projects/sessions, telescope search, git signs, problems panel. |
| `lua/plugins/lsp.lua` | Language servers (Mason), autocomplete, formatting. |
| `lua/plugins/treesitter.lua` | Syntax highlighting. |
| `lua/plugins/debug.lua` | Debugger (codelldb for C/C++, debugpy for Python). |
| `lua/plugins/terminal.lua` | Terminals inside nvim (toggleterm). |
| `after/ftplugin/*.lua` | Per-language indentation. |
| `keys.txt` | The shortcut cheat sheet. |

## Languages

These are set up: C/C++ (clangd), Python (basedpyright, autopep8), Lua, Bash, JavaScript/TypeScript and JSON. To add a language:
1. Install its tools with `:Mason` (`i` installs).
2. Add them to the `servers` or `tools` list in `lua/plugins/lsp.lua`, so a fresh install gets them too.
3. For the run button, add a line to `runners` in `lua/config/run.lua`.

For Python projects with a `.venv`, add this to the project's `pyproject.toml` so basedpyright finds the installed packages:

```toml
[tool.basedpyright]
venvPath = "."
venv = ".venv"
```

Python has no type checking or linting in the editor (basedpyright's type checks are off); run flake8 and mypy yourself, e.g. with `make lint`. autopep8 follows the project's `[flake8]` / `[pycodestyle]` settings.

Formatting is never automatic, because clang-format doesn't follow the Codam norm. `Space c f` formats when you want it.

## Credits

- Written by **Claude** (Anthropic) via Claude Code, together with me.
- Start screen, tabs bar and popups are based on [Danitell0/nvim-config](https://github.com/Danitell0/nvim-config).
- Colors come from [vscode.nvim](https://github.com/Mofiqul/vscode.nvim).
