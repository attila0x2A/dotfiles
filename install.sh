#!/usr/bin/env bash
#
# Bootstraps everything. Safe to re-run: every step checks whether it already
# happened before doing anything.
#
# Usage:
#   ./install.sh              (run from an existing checkout)
#   curl -fsSL https://raw.githubusercontent.com/attila0x2A/dotfiles/main/install.sh | bash   (fetches a fresh checkout to ~/dotfiles)

set -euo pipefail

DOTFILES_REPO="https://github.com/attila0x2A/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

log()  { printf '\033[1;32m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$1" >&2; }

# ---------------------------------------------------------------------------
# Package install helper.
# ---------------------------------------------------------------------------
pkg_install() {
  local pkg="$1"
  if command -v pacman >/dev/null; then
    sudo pacman -Sy && sudo pacman -S --noconfirm $pkg
  else
    warn "No supported package manager found for '$pkg'; install it manually."
    return 1
  fi
}

require_cmd() {
  local cmd="$1"
  shift
  local pkg="${@:-$cmd}"
  if command -v "$cmd" >/dev/null 2>&1; then
    log "$cmd already installed, skipping."
  else
    log "Installing $pkg..."
    pkg_install "$pkg"
  fi
}

aur_install() {
  local pkg="$1"
  if command -v pamac >/dev/null; then
    pamac build --no-confirm "$pkg"
  else
    warn "pamac not found for AUR package '$pkg'; install it manually."
    return 1
  fi
}

require_aur_cmd() {
  local cmd="$1"
  local pkg="${2:-$cmd}"
  if command -v "$cmd" >/dev/null 2>&1; then
    log "$cmd already installed, skipping."
  else
    log "Installing $pkg (AUR)..."
    aur_install "$pkg"
  fi
}

# ---------------------------------------------------------------------------
# Core tools
# ---------------------------------------------------------------------------
require_cmd stow
require_cmd nvim neovim
require_cmd rg ripgrep
require_cmd fzf
require_cmd gitleaks
require_cmd podman podman slirp4netns fuse-overlayfs shadow acl pass gnupg

require_aur_cmd caffeine caffeine-ng
require_aur_cmd google-chrome-stable google-chrome

# ---------------------------------------------------------------------------
# oh-my-zsh + zsh-autosuggestions
# ---------------------------------------------------------------------------
if [ -d "$HOME/.oh-my-zsh" ]; then
  log "oh-my-zsh already installed, skipping."
else
  log "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
AUTOSUGGESTIONS_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
if [ -d "$AUTOSUGGESTIONS_DIR" ]; then
  log "zsh-autosuggestions already installed, skipping."
else
  log "Installing zsh-autosuggestions..."
  git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
fi

# ---------------------------------------------------------------------------
# Fetch (or reuse) the dotfiles checkout
# ---------------------------------------------------------------------------
if [ -d "$DOTFILES_DIR/.git" ]; then
  log "Updating existing checkout at $DOTFILES_DIR..."
  git -C "$DOTFILES_DIR" pull --ff-only
else
  log "Cloning dotfiles to $DOTFILES_DIR..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# ---------------------------------------------------------------------------
# Stow
# ---------------------------------------------------------------------------
log "Stowing..."
cd "$DOTFILES_DIR"
stow -R vim shell opencode

# ---------------------------------------------------------------------------
# Trigger Neovim's plugin install (vim.pack.add in lua/plugins.lua runs
# on startup; this just does it once, non-interactively, up front).
# ---------------------------------------------------------------------------
log "Installing Neovim plugins (this may take a minute on first run)..."
nvim --headless "+quitall" 2>/dev/null || true

# ---------------------------------------------------------------------------
# Setup/update opencode-sandboxed
# ---------------------------------------------------------------------------
if command -v podman >/dev/null 2>&1 && id aiagent >/dev/null 2>&1; then
  log "Setting up acls for aiagent"

  # Only add ACL if aiagent doesn't already have that specific permission
  acl_set_if_missing() {
    local path="$1"
    local perm="$2"
    if ! getfacl -p "$path" 2>/dev/null | grep -q "^user:aiagent:.*${perm}"; then
      setfacl -m "u:aiagent:${perm}" "$path"
    fi
  }

  acl_set_if_missing "$HOME" x
  acl_set_if_missing "$HOME/.config" x
  acl_set_if_missing "$HOME/.config/opencode" x
  acl_set_if_missing "$HOME/.config/opencode/opencode.json" r
  acl_set_if_missing "$HOME/.config/opencode/AGENTS.md" r
  acl_set_if_missing "$HOME/.config/opencode-sandbox" x
  acl_set_if_missing "$HOME/.config/opencode-sandbox/squid.conf" r
  acl_set_if_missing "$HOME/.config/opencode-sandbox/Containerfile" r

  runas_aiagent() {
    sudo -u "aiagent" env XDG_RUNTIME_DIR="/run/user/$(id -u "aiagent")" "$@"
  }
  log "Building opencode-sandbox image..."
  runas_aiagent podman build -q -t opencode-sandbox \
      -f "$HOME/.config/opencode-sandbox/Containerfile" \
      "$HOME/.config/opencode-sandbox"

  log "Restarting opencode squid proxy if it's running..."
  PROXY_NAME="opencode-egress-proxy"
  runas_aiagent podman container exists "$PROXY_NAME" 2>/dev/null && \
    runas_aiagent podman container restart "$PROXY_NAME" 2>/dev/null
else
  warn "podman or aiagent user not found; skipping sandbox image build"
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

log "Done. Open a new shell (or 'exec zsh') to pick up the changes."
