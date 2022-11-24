_rc_g_set_gpg_tty() {
  export GPG_TTY="$(tty)"
  gpg-connect-agent updatestartuptty /bye | rg -Fv OK
  return $((pipestatus[1]))
}

_rc_g_reset_gpg() {
  timeout 5s systemctl --user restart gpg-agent.service
}

_rc_g_fix_gpg_tty() {
  if [[ "$DISPLAY" == :* ]]; then
    local old_tty="$GPG_TTY"

    unset GPG_TTY

    if [[ -n "$old_tty" ]] && _rc_g_has systemd; then
      ! [[ -t 2 ]] || echo $'\x1b[1;38;5;2mUnsetting GPG_TTY\x1b[m' >&2

      _rc_g_reset_gpg
    fi
  elif [[ -t 1 ]]; then
    ! [[ -t 2 ]] || echo $'\x1b[1;38;5;2mSetting GPG_TTY\x1b[m' >&2

    _rc_g_set_gpg_tty
  fi
}
