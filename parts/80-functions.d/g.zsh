typeset -Agx _rc_g_fn_gcmds

_rc_g_fn_gcmds+=(
  a   'add'
  aa  'add --all'
  ai  'add -i'
  ap  'add -p'
  b   'branch'
  c   'commit'
  ca  'commit --amend'
  can 'commit --amend --no-edit'
  cm  'commit -m'
  cl  'clone'
  co  'checkout'
  coh 'checkout HEAD'
  d   'diff'
  ds  'diff --stat'
  dm  'diff --diff-filter=MRT'
  f   'fetch'
  fa  'fetch --all'
  gr  'graph'
  l   'pull'
  m   'merge'
  p   'push'
  pa  'push --all'
  r   'remote'
  rb  'rebase'
  rbi 'rebase --interactive'
  rh  'reset HEAD'
  rst 'reset'
  s   'status'
  ss  'status --short'
  t   'stash'
  tp  'stash pop'
  sur 'submodule update --init --recursive --remote --force'
  wd  'word-diff'
)

function _rc_g_fn_gcmd() {
  local cmd
  cmd=${_rc_g_fn_gcmds[$1]}

  [[ -n "$cmd" ]] && echo -n "$cmd" || echo -n "$1"
}

# All of those git aliases, in one place (and not interfering with other commands)
function g() {
  if (( # == 0 )); then
    git help -a
    return $?
  fi

  cmd=$(_rc_g_fn_gcmd "$1")
  shift

  git ${(s: :)cmd[@]} $@
  return $?
}
