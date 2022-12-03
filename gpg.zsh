() {
  [[ -o rcs && -z "$ZRC_NO_GPG" && ! -v _rc_g_gpg ]] || return 0
  typeset -gA _rc_g_gpg
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


