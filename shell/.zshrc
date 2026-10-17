# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Local only configuration.
[ -f $HOME/.zsh/local.sh ] && source $HOME/.zsh/local.sh

zstyle ':omz:update' mode disabled
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="candy"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Prerequisites:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# Install fzf.

plugins+=(
    git
    zsh-autosuggestions
    fzf
    # fzf-tab
)

source $ZSH/oh-my-zsh.sh

# local.sh can add the aws plugin. Without the plugin, show no AWS profile.
(( $+functions[aws_prompt_info] )) || aws_prompt_info() {}

# User configuration

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# Custom prompts
# Reminder that ^Xu is undo.
# NOTE: Can add %n@%M is I care about username and hostname.
PS1='
%K{236}%F{112}%D{%b %d %H:%M:%S} %f %F{208}$(aws_prompt_info)%f %F{174}%~
%k%f^Xu$(git_prompt_info)%B(%h) %# %b'
RPROMPT=""

# Important for things like git commit.
export EDITOR=nvim

# Text to image helper.
to_image() {
    # "FreeMono" -border 300
    convert -size 15000x30000 xc:white -density 300 -font "Courier-BoldOblique" -pointsize 12 -interline-spacing 60 -fill black -annotate +150+150 "@$1" -trim  -bordercolor "#FFF" -border 300 +repage "$2"
}

start_work() {
    tmux new-session -A -s work
}
zle -N start_work{,}
# Ctrl+s to start work.
bindkey -s '^s' 'start_work\n'

# Tmux windows renaming
function tmux_title() {
  tmux rename-window "$(basename `pwd`)"
}
if [[ ! -z "$TMUX" ]]; then
  precmd_functions+=(tmux_title)
fi

alias htail='(sed -u 10q; tail -100)'
alias ls='ls -F --color=always'
alias ll='ls -lh --color=always'
alias vim="nvim"
alias v="nvim"
function vd() {
  if [[ "$#" != 0 ]]
  then
    v +"Git difftool -y $(git merge-base ${*} HEAD)"
  else
    v +"Git difftool -y $(git merge-base master HEAD)"
  fi
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [[ -d $HOME/.pyenv ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - zsh)"
fi

typeset -U path
path=(/usr/local/go/bin ~/go/bin ~/.cargo/bin $path)

# Use rg (ripgrep) or ag (silver searcher) for fzf.
if command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --bind 'alt-a:select-all,alt-d:deselect-all'"


# Use fzf for gco if no arguments are set.
# By default gco is an alias to git checkout.
# unalias gco
# gco() {
#   if [[ "$#" != 0 ]]
#   then
#     git checkout "${*}"
#   else
#     git branch | grep -v "^\*" | fzf --height=20% --reverse --info=inline | xargs git checkout
#   fi
# }
# compdef _git gco=git-checkout

unalias gcm
alias gcm="git checkout master"
