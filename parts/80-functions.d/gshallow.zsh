function gshallow() {
  [[ -t 1 ]] && echo -n $'\x1b[1;38;5;1m'
  echo -n "WARNING: THIS CAN RESULT IN LOST WORK"
  [[ -t 1 ]] && echo -n $'\x1b[m'
  echo

  [[ "$(_rc_g_yn 'Really continue? [y/N] ' n)" == y ]] || return 1

  local depth="${1:-1}"
  (( # > 1 )) && shift

  echo "Performing fetch with depth $depth..."
  git fetch --depth "$depth" || return "$?"
  echo 'Expiring reflog...'
  git reflog expire --expire=all --all || return "$?"
  echo 'Running GC...'
  git gc --aggressive --prune=all || return "$?"
}
