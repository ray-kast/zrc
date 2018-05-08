function help() {
  if (( # != 1 )); then
    echo "Usage: help <command>"

    return 1
  fi

  "$1" --help
}
