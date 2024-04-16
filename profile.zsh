# Run this script from .zprofile

false && alias _='print' || alias _=':'

######## Begin alternate system-level package managers

if [[ -d "$HOME/.local/bin" ]]; then
  _ local-bin
  export PATH="$PATH:$HOME/.local/bin"
fi

if (( $+commands[snap] )); then
  _ snap
  export PATH="$PATH:/snap/bin"
fi

if [[ -x '/opt/local/bin/port' ]]; then
  _ port
  export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
fi

######## End system-level package managers

if (( $+commands[cargo] )) || (( $+commands[rustup] )) || [[ -x "$HOME/.cargo/bin/rustup" ]]; then
  _ cargo
  export PATH="/usr/lib/cargo/bin:$HOME/.cargo/bin:$PATH"
fi

if [[ -e '/opt/local/share/dotnet' ]]; then
  _ dotnet
  export DOTNET_ROOT='/opt/local/share/dotnet'
fi

if  [[ -x "$HOME/.elan/bin/elan" ]]; then
  _ elan
  export PATH="$HOME/.elan/bin:$PATH"
fi

if (( $+commands[ruby] )) && (( $+commands[gem] )); then
  _ gem
  export PATH="$PATH:$(ruby -r rubygems -e 'puts Gem.user_dir')/bin"
fi

if [[ -s "$GOPATH" ]]; then
  _ go
  export PATH="$PATH:$GOPATH/bin"
fi

_ gpg
. "$(dirname "$0")"/gpg.zsh

() {
  local f="$commands[nodenv]"

  if [[ -z "$f" && -d "$HOME/.nodenv" ]]; then
    export PATH="$PATH:$HOME/.nodenv/bin"

    f="$commands[nodenv]"
  else
    return
  fi

  _ nodenv
  . <("$f" init - zsh | cat)
}

if (( $+commands[rbenv] )); then
  _ rbenv
  . <(rbenv init - zsh | cat)
elif [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  _ rvm
  . "$HOME/.rvm/scripts/rvm"
fi

if [[ -d "$HOME/.rakudobrew" ]]; then
  _ rakudobrew
  . <("$HOME/.rakudobrew/bin/rakudobrew" init - | cat)
fi

if (( $+commands[yarn] )); then
  _ yarn
  export PATH="$PATH:$HOME/.yarn/bin"
fi

######## Begin PATH overrides

if (( $+commands[port] )); then
  export PATH="/opt/local/libexec/gnubin:$PATH"
fi

######## End PATH overrides

unalias _
