# AGENTS.md

Dotfiles managed via GNU stow. No build, test, or lint commands — this is not a software project.

## Important constraints for editing

- Files under `vim/.config/nvim/`, `shell/`, and `opencode/` are **managed by stow**.
  Editing them here edits the deployed symlink target; changes take effect immediately.

## Deployment

- **Install/update**: `./install.sh` (idempotent, safe to re-run, uses `stow -R`)
- **Default checkout path**: `~/dotfiles` (override via `DOTFILES_DIR` env var)
- `install.sh` handles macOS (brew) and Linux (apt or pacman).

## Key conventions

- **Neovim >= 0.12** required — uses built-in `vim.pack.add` for plugins (not lazy.nvim, packer, etc.)
- **Plugin management**: add a URL in `vim/.config/nvim/lua/plugins.lua`, remove stale entries with `vim.pack.del()`.
  Non-active plugins are auto-removed on `VimEnter`.
- **Default colorscheme**: gruvbox
- **Rust-focused**: debug/test keybindings (`TPrint`, `TRun`, `TDebug`, etc.) invoke `cargo test` and `lldb`.
- **Shell**: zsh + oh-my-zsh. Editor is `nvim`. FZF uses `ag` (the_silver_searcher) as default.
- gitignored: `shell/.zsh/local.sh` (sourced as local-only overrides) and `beancount-language-server.log`.

## OpenCode sandbox

- `opencode/.local/bin/grant-agent-access <dir>` — recursively sets ACLs so the `aiagent` user can rwx a working directory
- `opencode/.local/bin/opencode-sandboxed` — runs opencode inside a rootless podman container with egress restricted via squid proxy; state persists to `~/.config/opencode-sandbox/data/`; any arguments are forwarded to the opencode command

## Permission restrictions

These are enforced and will fail if attempted.

- `git push*` — denied
- `sudo *` — denied
- `curl * | *` — denied (piped installs)
- `rm -rf *` — denied
- External directories outside `/tmp/opencode` — denied
- Secret files blocked: `.env`, `.pem`, `.key`, `.ssh/**`, `.aws/**`, `.gnupg/**`, `**/secrets/**`, `**/credentials/**`, `.netrc`, `.git-credentials`, `.git/config`, `id_rsa*`, `id_ed25519*`
- Editing, writing, bash, webfetch — requires user approval per action
- Pre-approved commands: `git status`, `git diff`, `git log`
