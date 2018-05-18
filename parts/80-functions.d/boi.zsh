function boi() {
  if { fc -lLIn 1>/dev/null 2>/dev/null }; then
    [[ $+functions[__rc_i_boi_cmd] ]] && unset 'functions[__rc_i_boi_cmd]'

    cmd=$(fc -lLIn | tail -n1)
    functions[__rc_i_boi_cmd]=$cmd

    if [[ $+functions[__rc_i_boi_cmd] ]]; then
      echo "Executing '$cmd'..." >&2

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