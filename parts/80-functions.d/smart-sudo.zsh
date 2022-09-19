function smart-sudo() {
  if (( # > 0 )); then
    [[ $+functions[__rc_i_s_cmd] ]] && unset 'functions[__rc_i_s_cmd]'

    local cmd="$@"
    functions[__rc_i_s_cmd]=$cmd

    if [[ $+functions[__rc_i_s_cmd] ]]; then
      sudo sh -c "${functions[__rc_i_s_cmd]#$'\t'}"

      return $?
    else
      echo "Failed to resolve '$cmd'." >&2

      return 2
    fi
  else
    echo "Usage: s <command...>" >&2

    return 1
  fi
}

alias s="smart-sudo"
