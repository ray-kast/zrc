typeset -Agx _rc_g_fn_gcmds

_rc_g_fn_gcmds+=(
  a   'add'
  aa  'add --all'
  ai  'add -i'
  ap  'add -p'
  b   'branch'
  bd  'branch -D'
  bl  'branch --list'
  c   'commit'
  ca  'commit --amend'
  can 'commit --amend --no-edit'
  cm  'commit -m'
  cl  'clone'
  co  'checkout'
  coh 'checkout HEAD'
  d   'diff'
  dc  'diff --cached'
  dcs 'diff --cached --stat'
  ds  'diff --stat'
  dm  'diff --diff-filter=MRT'
  f   'fetch'
  fa  'fetch --all'
  gr  'graph'
  gra 'graph --all'
  h   'show'
  hs  'show --stat'
  l   'pull'
  la  'pull --all'
  m   'merge'
  ma  'merge --abort'
  p   'push'
  pa  'push --all'
  pf  'push -f'
  pfa 'push --all -f'
  pu  'push -u'
  r   'remote'
  ra  'remote add'
  rb  'rebase'
  rba 'rebase --abort'
  rbi 'rebase --interactive'
  rh  'reset HEAD'
  rhh 'reset HEAD --hard'
  rs  'reset'
  rsh 'reset --hard'
  s   'status'
  ss  'status --short'
  t   'stash'
  tk  'stash -k'
  tl  'stash list'
  tp  'stash pop'
  sui 'submodule update --init --recursive'
  sur 'submodule update --init --recursive --remote'
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
