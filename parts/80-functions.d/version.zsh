function version() {
  if (( # != 1 )); then
    echo "Usage: version <command>"

    return 1
  fi

  "$1" --version
}
