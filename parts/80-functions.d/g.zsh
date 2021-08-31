typeset -Agx _rc_g_fn_gcmds

_rc_g_fn_gcmds+=(
  a   'add'
  aa  'add --all'
  ai  'add -i'
  ap  'add -p'
  b   'branch'
  ba  'branch -a'
  bd  'branch -D'
  bf  'branch -f'
  bl  'branch --list'
  bv  'branch -vv'
  c   'commit'
  ca  'commit --amend'
  can 'commit --amend --no-edit'
  cm  'commit -m'
  cl  'clone'
  cp  'cherry-pick'
  cpa 'cherry-pick --abort'
  cpc 'cherry-pick --continue'
  cxf 'clean -xf'
  cxi 'clean -xi'
  cxn 'clean -xn'
  d   'diff'
  dc  'diff --cached'
  dcs 'diff --cached --stat'
  dm  'diff --diff-filter=MRT'
  dni 'diff --no-index'
  ds  'diff --stat'
  e   'restore'
  es  'restore --staged'
  f   'fetch'
  fa  'fetch --all -p'
  gr  'graph'
  gra 'graph --all'
  h   'show'
  hs  'show --stat'
  l   'pull -p'
  la  'pull -p --all'
  m   'merge'
  ma  'merge --abort'
  p   'push'
  pa  'push --all'
  pd  'push -d'
  pu  'push -u'
  r   'remote'
  ra  'remote add'
  rv  'remote -v'
  rb  'rebase'
  rba 'rebase --abort'
  rbc 'rebase --continue'
  rbi 'rebase --interactive'
  rbo 'rebase --onto'
  rbs 'rebase --skip'
  rh  'reset HEAD'
  rs  'reset'
  s   'status'
  ss  'status --short'
  sua 'status -uall'
  t   'stash'
  tk  'stash -k'
  tl  'stash list'
  tp  'stash pop'
  tu  'stash push'
  sui 'submodule update --init --recursive'
  sur 'submodule update --init --recursive --remote'
  wd  'word-diff'
  w   'switch'
  wc  'switch -c'
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
