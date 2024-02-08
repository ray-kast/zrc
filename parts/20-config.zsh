_rc_g_has emacs && export EDITOR="emacs"
_rc_g_has nano && export EDITOR="nano"
_rc_g_has vi && export EDITOR="vi"
_rc_g_has vim && export EDITOR="vim"
_rc_g_has nvim && export EDITOR="nvim"
export PAGER="less -QRS"
export PATH="$PATH:$HOME/.zrc/bin"
export VISUAL="$EDITOR"
_rc_g_has code && export VISUAL="code --new-window -g --wait -- "
_rc_g_has nvim && export VISUAL="nvim"

# zsh internals
HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory autocd extendedglob nobeep nomatch

setopt histexpiredupsfirst histignoredups histnostore histreduceblanks sharehistory histignorespace

DIRSTACKSIZE=20
setopt autopushd pushdminus pushdsilent pushdtohome

WORDCHARS=${WORDCHARS//[\/.-]}

# dotnet
export PATH="$PATH:$HOME/.dotnet/tools"

# fzf
_rc_g_has fzf && _rc_g_has fd && export FZF_DEFAULT_COMMAND='fd -uu .'

# go
export GOPATH="$HOME/Documents/Go"

# less
export LESS="-QRS"
export LESSEDIT="%E %f?lm\:%lm."

# ls
source <(dircolors -b)

# nvm
() {
  local f

  (( $+functions[nodenv] )) && return

  for f in /{usr,opt/local}/share/nvm/init-nvm.sh "$HOME/.nvm/nvm.sh"; do
    echo $'\e[1;38;5;1mWARNING:\e[0;1m nvm found but not nodenv\x1b[m'

    if [[ -s "$f" ]]; then
      . "$f"
      break
    fi
  done
}

# rvm
export PATH="$PATH:$HOME/.rvm/bin"

# TODO: what was this supposed to be? This directory doesn't exist.
# # rust
# export RUST_SRC_PATH=~/.multirust/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src/

# virtualenv
export VIRTUAL_ENV_DISABLE_PROMPT=1

# texlive
export TEXMFLOCAL=/usr/local/texmf

# terminal (warn if not using single-instance Kitty)
if (( $+commands[kitty] )) && ! (( $+commands[kitty1] )); then
  echo $'\e[1;38;5;1mWARNING:\e[0;1m kitty found but not kitty1 -- using non-single-instance\x1b[m'
fi

