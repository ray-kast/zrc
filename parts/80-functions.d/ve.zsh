function ve() {
  local dir

  dir="$1"

  shift || return 1

  virtualenv "$HOME/.venv/$dir" $@
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
