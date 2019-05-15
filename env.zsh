#!/usr/bin/zsh
# Run this script from .zshenv

# Not exporting .zrc/bin because it's really just interactive utilities

# cargo
export PATH=$PATH:$HOME/.cargo/bin

# gem
if { which ruby && which gem } >/dev/null; then
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

