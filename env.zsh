#!/usr/bin/zsh
# Run this script from .zshenv

false && alias _='print' || alias _=':'

_ rxvt # Weird edge-case logic to try to fix rxvt issues with ssh
[[ "$SHLVL" -eq 1 && -n "$TERM" ]] && export TERM="${TERM/rxvt(-unicode|)/xterm}"

# Not exporting .zrc/bin because it's really just interactive utilities

_ locale
[[ -v LC_ALL ]] || export LC_ALL="en_US.UTF-8"
[[ -v LC_CTYPE ]] || export LC_CTYPE="en_US.UTF-8"

() {
  if [[ -z "$TERMINAL" ]]; then
    _ terminal
    local term
    for term in kitty1 kitty terminal; do
      if (( $+commands[$term] )) >/dev/null; then
        export TERMINAL="$commands[$term]"
        break
      fi
    done
  fi
}

if (( $+commands[snap] )); then
  _ snap # doing this first because it's system-level
  export PATH="$PATH:/snap/bin"
fi

if (( $+commands[cargo] )) || [[ -x "$HOME/.cargo/bin/rustup" ]]; then
  _ cargo
  export PATH="$PATH:/usr/lib/cargo/bin:$HOME/.cargo/bin"
fi

if (( $+commands[ruby] )) && (( $+commands[gem] )); then
  _ gem
  export PATH="$PATH:$(ruby -r rubygems -e 'puts Gem.user_dir')/bin"
fi

if [[ -s "$GOPATH" ]]; then
  _ go
  export PATH="$PATH:$GOPATH/bin"
fi

() {
  _ gpg
  typeset -gA _rc_g_gpg

  [[ -o rcs && -z "$ZRC_NO_GPG" ]] || return 0
  _rc_g_gpg[enabled]=1

  (( $+commands[gpgconf] )) || return 0
  local gpg_sock="$(gpgconf --list-dirs agent-ssh-socket)"

  if [[ "$SSH_AGENT_PID" -ne 0 || (-n "$SSH_AUTH_SOCK" && "$SSH_AUTH_SOCK" != "$gpg_sock") ]]
    then _rc_g_gpg[already-running]=1 fi

  # If this is an interactive session and we can probably spawn gpg-agent
  # without causing trouble, do it.
  if [[ ! -S "$gpg_sock" && -o interactive ]] \
    && (( $+commands[gpg-connect-agent] && ! $+commands[systemd] )); then
    [[ -t 2 ]] && echo $'\x1b[1;38;5;2mSpawning gpg-agent\x1b[m'
    gpg-connect-agent /bye
    gpg_sock="$(gpgconf --list-dirs agent-ssh-socket)"
  fi

  [[ -S "$gpg_sock" ]] || return 0
  _rc_g_gpg[found]=1

  if [[ "$(uname)" == 'Darwin' ]] || [[ "$DISPLAY" == :* ]]
    then _rc_g_gpg[gui]=1 fi

  export SSH_AGENT_PID=''
  export SSH_AUTH_SOCK="$gpg_sock"
}

() {
  local f

  for f in /usr/share/nvm/init-nvm.sh "$HOME/.nvm/nvm.sh"; do
    if [[ -s "$f" ]]; then
      _ nvm
      . "$f"
      break
    fi
  done
}

if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  _ rvm
  . "$HOME/.rvm/scripts/rvm"
fi

if [[ -d "$HOME/.rakudobrew" ]]; then
  _ rakudobrew
  source <("$HOME/.rakudobrew/bin/rakudobrew" init -)
fi

if (( $+commands[yarn] )); then
  _ yarn
  export PATH="$PATH:$HOME/.yarn/bin"
fi

unalias _
