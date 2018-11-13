export EDITOR="vim"
export PAGER="less -QRS"
export PATH="$PATH:$HOME/.zrc/bin"
export VISUAL="code --new-window -g --wait -- "

# zsh internals
HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory autocd extendedglob nobeep nomatch

setopt histexpiredupsfirst histignoredups histnostore histreduceblanks sharehistory

DIRSTACKSIZE=20
setopt autopushd pushdminus pushdsilent pushdtohome

# less
export LESS="-QRS"
export LESSEDIT="%E %f?lm\:%lm."

# ls
source <(dircolors -b)

# rust
export RUST_SRC_PATH=~/.multirust/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src/

# texlive
export TEXMFLOCAL=/usr/local/texmf
