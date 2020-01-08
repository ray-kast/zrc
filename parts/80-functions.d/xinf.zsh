function xinf() {
  local delay="0"

  if (( $# > 0 )); then
    delay=$1
    shift
  fi

  sleep "$delay"

  echo "Select a window..."

  local id="$(xwininfo | awk '/Window id:/{print $4}')"

  {
    echo "\e[1m==== OUTPUT OF XWININFO ====\e[m\n"

    xwininfo -id "$id"

    echo "\n\e[1m==== OUTPUT OF XPROP ====\e[m\n"

    xprop -id "$id"
  } | less
}
