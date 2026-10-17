# AGENTS.md

Dotfiles managed via GNU stow. Directory trees mirror `$HOME` (e.g. `vim/.config/nvim/` → `~/.config/nvim/`).

## Key conventions

- `./install.sh` deploys with `stow -R`. Override checkout dir via `DOTFILES_DIR`.
- Neovim >= 0.12 with built-in `vim.pack.add` (no lazy.nvim/packer). Plugins defined in `vim/.config/nvim/lua/plugins.lua`.
- Shell: zsh + oh-my-zsh. Editor: `nvim`.
- Language-specific ftplugins: `vim/.config/nvim/ftplugin/*.vim`
- Stale plugins auto-removed on `VimEnter`.

## Bluetooth

- `bluetooth/` is stowed with `--no-folding`, so `~/.config/systemd/user/` and `~/.config/wireplumber/` stay real directories.
- `bt-laptop-initiated-reconnect@<address>.service` reconnects a device from the laptop when the device starts the connection (MT7925 role switch stutter). `install.sh` enables it for the paired devices in `BT_RECONNECT_DEVICES`.

## OpenCode config

- `opencode/.config/opencode/opencode.json` — model, provider, permissions, compaction
- `opencode/.config/opencode/AGENTS.md` — global agent rules
- Sandbox configs under `opencode/.config/opencode-sandbox/`

## Adding a provider

Four files. Pattern per provider:

1. `opencode/.config/opencode/opencode.json` → `provider` block. Built-in providers (anthropic, google) need `"<name>": {}` or nothing. Custom providers need `npm`, `options.baseURL`, `models`.
2. `opencode/.local/bin/opencode-sandboxed` → read key with `pass show <vendor>/<product>-api-key`, export as `-e <PROVIDER>_API_KEY`.
3. `opencode/.config/opencode-sandbox/squid.conf` → add API domain to `models_dst` acl.
4. `README.md` → add `pass insert <vendor>/<product>-api-key`.

Store key in `pass`, restart opencode.

## Permission rules

See `opencode/.config/opencode/opencode.json` → `permission`. Pre-approved: `git status`, `git diff`, `git log`. All other tool use requires explicit approval.
