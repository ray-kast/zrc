function ve() {
  local dir python pyver venv

  dir="$1"
  shift || return 1

  python="$1"
  shift || python="python"
  python="$(which "$python")"

  pyver="$({ "$python" --version 2>&1 } | awk -F' ' '/python/i { print $2 }')"

  echo "\x1b[1m==> Python version detected: $pyver\x1b[m"

  if { "$python" -c 'import venv' >/dev/null 2>/dev/null }; then
    echo "\x1b[1m==> Using venv module...\x1b[m"
    venv=("$python" -m venv)
  else
    echo "\x1b[1;38;5;3m=!> Using virtualenv...\x1b[m"
    venv=("$(which virtualenv)" -p "$python")
  fi

  "${(@)venv}" "$HOME/.venv/$dir"

  return $?
}

function ve-rm() {
  rm -rf "$HOME/.venv/$1"
}

function ve-ls() {
  ls -lahbF --color "$HOME/.venv/$1"
}

function va() {
  source "$HOME/.venv/$1/bin/activate"
}

alias vd='deactivate'
