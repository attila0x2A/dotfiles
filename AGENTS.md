# AGENTS.md

Dotfiles managed via GNU stow. Directory trees mirror `$HOME` (e.g. `vim/.config/nvim/` → `~/.config/nvim/`).

## Key conventions

- `./install.sh` deploys with `stow -R`. Override checkout dir via `DOTFILES_DIR`.
- Neovim >= 0.12 with built-in `vim.pack.add` (no lazy.nvim/packer). Plugins defined in `vim/.config/nvim/lua/plugins.lua`.
- Shell: zsh + oh-my-zsh. Editor: `nvim`.
- Language-specific ftplugins: `vim/.config/nvim/ftplugin/*.vim`
- Stale plugins auto-removed on `VimEnter`.

## OpenCode config

- `opencode/.config/opencode/opencode.json` — model, provider, permissions, compaction
- `opencode/.config/opencode/instructions.md` — global conciseness rules
- Sandbox configs under `opencode/.config/opencode-sandbox/`

## Permission rules

See `opencode/.config/opencode/opencode.json` → `permission`. Pre-approved: `git status`, `git diff`, `git log`. All other tool use requires explicit approval.
