## Installation

```shell
curl -fsSL https://raw.githubusercontent.com/attila0x2A/dotfiles/main/install.sh | bash
```

This installs and configures everything. Safe to re-run any time.

<details>
<summary>Manual install (if you'd rather not pipe a script to bash)</summary>

1. Install stow, neovim, fzf, and ag (e.g. `brew install stow neovim fzf
   the_silver_searcher` on macOS, or the equivalent apt packages on Linux).

1. Install oh-my-zsh and zsh-autosuggestions:

    ```shell
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    ```

1. Clone and stow:

    ```shell
    git clone https://github.com/attila0x2A/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    stow -R vim shell
    ```

1. Open `nvim` once to let `vim.pack` install the plugins.

</details>

## Updating

```shell
./install.sh
```

or, if you just changed a dotfile and don't need to reinstall anything:

```shell
stow -R vim shell
```

## Additional configurations

* Setup ssh for Github, use ssh-agent to access keys with password. Keys
  should be passphrase protected.

* To open terminal maximized run `exo-preferred-applications` and change
  TerminalEmulator to `/usr/bin/xfce4-terminal --maximize`

* Download and install from [Dropbox.com](https://www.dropbox.com/install-linux)
