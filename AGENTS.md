# AGENTS.md

Dotfiles managed via GNU stow. Not a software project — no build, test, or lint.

## Stow conventions

- Directory trees under repo root mirror `$HOME`.
  Example: `vim/.config/nvim/` → `~/.config/nvim/`
- Adding a new config: create the mirrored path, then add its top-level directory
  name to the `stow -R` command in `install.sh`.
- Files under `vim/.config/nvim/`, `shell/`, and `opencode/` are managed by stow.
  Editing them here edits the symlink target directly — changes take effect immediately.

## Deployment

- `./install.sh` (idempotent, safe to re-run, uses `stow -R`)
- Default checkout: `~/dotfiles` (override via `DOTFILES_DIR`)
- macOS (brew) and Arch Linux (pacman)

## Key conventions

- **Neovim >= 0.12** — built-in `vim.pack.add` (no lazy.nvim, packer, etc.)
- **Plugin management**: add a URL in `vim/.config/nvim/lua/plugins.lua`.
  Stale non-active plugins are auto-removed on `VimEnter`. Remove manually:
  `:lua vim.pack.del({'plugin-name'})`
- **Colorscheme**: gruvbox
- **Rust-focused**: debug/test keybindings (`TPrint`, `TRun`, `TDebug`, etc.)
- **Shell**: zsh + oh-my-zsh. Editor is `nvim`. FZF uses `ag`.
- **Language-specific ftplugins**: `vim/.config/nvim/ftplugin/*.vim`
  (indentation, formatting per filetype)
- gitignored: `shell/.zsh/local.sh`, `beancount-language-server.log`,
  `opencode/.config/opencode-sandbox/data/`

## OpenCode config

- `opencode/.config/opencode/opencode.json` — model, provider, permissions, compaction
- `opencode/.config/opencode/instructions.md` — global conciseness rules
  (loaded separately from this file via `instructions` field in opencode.json)
- `opencode/.config/opencode-sandbox/` — sandbox build and egress:
  - `squid.conf` — allowed outbound domains (add new domains here)
  - `Containerfile` — pinned Arch base + installed dev tools
- Sandbox scripts:
  - `opencode/.local/bin/opencode-sandboxed` — launch container
  - `opencode/.local/bin/grant-agent-access <dir>` — set ACLs for `aiagent` user
- Rebuild sandbox image after Containerfile changes:
  ```
  podman build -t opencode-sandbox ~/.config/opencode-sandbox/
  ```

## Permission rules

See `opencode/.config/opencode/opencode.json` → `permission` for the
authoritative rules. Pre-approved: `git status`, `git diff`, `git log`.
All other tool use requires explicit approval per action.
