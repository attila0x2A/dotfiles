## Installation

```shell
curl -fsSL https://raw.githubusercontent.com/attila0x2A/dotfiles/main/install.sh | bash
```

This installs and configures everything. Safe to re-run any time.

## Updating

```shell
./install.sh
```

## Agent setup

1. Create a dedicated user:
   ```shell
   sudo useradd -m -s /usr/bin/bash aiagent
   sudo passwd -l aiagent
   sudo usermod --add-subuids 200000-265535 --add-subgids 200000-265535 aiagent
   sudo loginctl enable-linger aiagent
   ```

   Verify:
   ```shell
   grep aiagent /etc/subuid /etc/subgid
   ```

1. Rootless Podman for `aiagent`
   ```shell
   sudo machinectl shell aiagent@
   # --- now inside a shell as aiagent ---
   podman system migrate
   podman info --format '{{.Host.Security.Rootless}}'   # must print "true"
   exit
   ```

1. Setup secrets for `aiagent`
   ```shell
   sudo machinectl shell aiagent@
   # --- as aiagent ---
   gpg --quick-gen-key "aiagent@localhost" default default never
   pass init "aiagent@localhost"
   pass insert deepseek/opencode-api-key
   pass insert google/gemini-api-key
   exit
   ```

1. Run `./install.sh` to finish setup.


## Additional configurations

* Setup ssh for Github, use ssh-agent to access keys with password. Keys
  should be passphrase protected.

* To open terminal maximized run `exo-preferred-applications` and change
  TerminalEmulator to `/usr/bin/xfce4-terminal --maximize`

* Download and install from [Dropbox.com](https://www.dropbox.com/install-linux)
