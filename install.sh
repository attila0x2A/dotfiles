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

OS="$(uname -s)"

# ---------------------------------------------------------------------------
# Package install helper: uses brew on macOS, pacman on Arch Linux.
# Anything else gets a warning and a manual-install hint instead of failing.
# ---------------------------------------------------------------------------
pkg_install() {
  local pkg="$1"
  case "$OS" in
    Darwin)
      command -v brew >/dev/null || {
        warn "Homebrew not found; install it from https://brew.sh first."
        return 1
      }
      brew install $pkg
      ;;
      Linux)
      if command -v pacman >/dev/null; then
        sudo pacman -Sy && sudo pacman -S --noconfirm $pkg
      else
        warn "No supported package manager found for '$pkg'; install it manually."
        return 1
      fi
      ;;
    *)
      warn "Unsupported OS '$OS' for '$pkg'; install it manually."
      return 1
      ;;
  esac
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

# ---------------------------------------------------------------------------
# Core tools
# ---------------------------------------------------------------------------
require_cmd stow
require_cmd nvim neovim
require_cmd fzf
require_cmd gitleaks
require_cmd opencode
require_cmd podman podman slirp4netns fuse-overlayfs shadow acl pass gnupg

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
# Done
# ---------------------------------------------------------------------------

log "Done. Open a new shell (or 'exec zsh') to pick up the changes."
