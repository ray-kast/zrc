export EDITOR="vim"
export PAGER="less -QRS"
export PATH="$PATH:$HOME/.zrc/bin"
_rc_g_has code && export VISUAL="code --new-window -g --wait -- "
_rc_g_has nvim && export VISUAL="nvim"

# zsh internals
HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory autocd extendedglob nobeep nomatch

setopt histexpiredupsfirst histignoredups histnostore histreduceblanks sharehistory

DIRSTACKSIZE=20
setopt autopushd pushdminus pushdsilent pushdtohome

# go
export GOPATH="$HOME/Documents/Go"

# less
export LESS="-QRS"
export LESSEDIT="%E %f?lm\:%lm."

# ls
source <(dircolors -b)

# TODO: what was this supposed to be? This directory doesn't exist.
# # rust
# export RUST_SRC_PATH=~/.multirust/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src/

# virtualenv
export VIRTUAL_ENV_DISABLE_PROMPT=1

# texlive
export TEXMFLOCAL=/usr/local/texmf
