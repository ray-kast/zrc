function boi() {
  if { fc -lLIn 1>/dev/null 2>/dev/null }; then
    [[ $+functions[__rc_i_boi_cmd] ]] && unset 'functions[__rc_i_boi_cmd]'

    local cmd=$(fc -lLIn | tail -n1)
    functions[__rc_i_boi_cmd]=$cmd

    if [[ $+functions[__rc_i_boi_cmd] ]]; then
      [[ $(_rc_g_yn "Execute '$cmd'? [y/N] " n) == 'y' ]] || return -1

      sudo sh -c "${functions[__rc_i_boi_cmd]#$'\t'}"

      return $?
    else
      echo "Failed to resolve '$cmd'." >&2

      return 2
    fi
  else
    echo "No events available." >&2

    return 1
  fi
}

alias fucc="boi"
