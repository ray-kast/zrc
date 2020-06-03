#!/usr/bin/zsh
# Run this script from .zshenv

# Weird edge-case logic to try to fix rxvt issues with ssh
(( SHLVL == 1 )) && export TERM="${TERM/rxvt(-unicode|)/xterm}"

# Not exporting .zrc/bin because it's really just interactive utilities

[[ -v LC_ALL ]] || export LC_ALL="" # Yeah, this is redundant, but not if I ever change LC_ALL
[[ -v LC_CTYPE ]] || export LC_CTYPE="en_US.UTF-8"

if [[ -z "$TERMINAL" ]]; then
  for term in kitty terminal; do
    if (( $+commands[$term] )) >/dev/null; then
      export TERMINAL="$commands[$term]"
      break
    fi
  done
fi

# snap (doing this first because it's system-level)
export PATH="$PATH:/snap/bin"


# cargo
export PATH="$PATH:$HOME/.cargo/bin"

# gem
if (( $+commands[ruby] )) && (( $+commands[gem] )); then
  export PATH="$PATH:$(ruby -r rubygems -e 'puts Gem.user_dir')/bin"
fi

# go
if [[ -s "$GOPATH" ]]; then
  export PATH="$PATH:$GOPATH/bin"
fi

# rvm
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  . "$HOME/.rvm/scripts/rvm"
fi

# rakudobrew
if [[ -d "$HOME/.rakudobrew" ]]; then
  source <("$HOME/.rakudobrew/bin/rakudobrew" init -)
fi

# yarn
export PATH="$PATH:$HOME/.yarn/bin"

