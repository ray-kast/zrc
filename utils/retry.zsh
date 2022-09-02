function _rc_g_retry() {
  local tries="$1" name="$2" ret=1
  shift 2 || return -1

  while (( ret != 0 && tries != 0 )); do
    "${(@)@}"
    ret=$?

    if (( ret != 0 && tries < 0 )) && [[ "$(_rc_g_yn "$1 failed; retry? [Y/n] " y)" != 'y' ]]; then
      ret=0
    fi
  done

  if (( ret != 0 && tries == 0 )); then
    echo "$1 failed!" >&2
  fi

  return "$ret"
}
