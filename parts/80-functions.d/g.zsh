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
  co  'checkout'
  cp  'cherry-pick'
  cpa 'cherry-pick --abort'
  cpc 'cherry-pick --continue'
  cxi 'clean -xi'
  cxn 'clean -xn'
  d   'diff'
  dc  'diff --cached'
  dcs 'diff --cached --stat'
  dm  'diff --diff-filter=MRT'
  dni 'diff --no-index'
  ds  'diff --stat'
  e   'restore'
  ep  'restore -p'
  es  'restore --staged'
  esp 'restore --staged -p'
  f   'fetch'
  fa  'fetch --all -p'
  gr  'graph'
  gra 'graph --all'
  h   'show'
  hs  'show --stat'
  id  'diff --ignore-all-space'
  idc 'diff --ignore-all-space --cached'
  ih  'show --ignore-all-space'
  l   'pull -p'
  la  'pull -p --all'
  m   'merge'
  ma  'merge --abort'
  mf  'merge --ff-only'
  p   'push'
  pd  'push -d --no-verify'
  pu  'push -u'
  # TODO: re-enable these if we re-enable signed pushes by default
  # pn  'push --no-signed'
  # pnd 'push --no-signed -d --no-verify'
  # pnu 'push --no-signed -u'
  r   'remote'
  ra  'remote add'
  rv  'remote -v'
  rb  'rebase'
  rba 'rebase --abort'
  rbc 'rebase --continue'
  rbi 'rebase --interactive'
  rbo 'rebase --onto'
  rbs 'rebase --skip'
  rl  'reflog'
  rh  'reset HEAD'
  rs  'reset'
  s   'status'
  ss  'status --short'
  sua 'status -uall'
  t   'stash'
  ta  'stash apply'
  tk  'stash -k'
  tl  'stash list'
  tp  'stash pop'
  tu  'stash push'
  sui 'submodule update --init --recursive'
  sur 'submodule update --init --recursive --remote'
  wd  'word-diff'
  wdc 'word-diff --cached'
  wh  'word-show'
  Wd  'big-word-diff'
  Wdc 'big-word-diff --cached'
  Wh  'big-word-show'
  w   'switch'
  wc  'switch -c'
  w-  'switch -'
)

function _rc_g_fn_gcmd() {
  local cmd="${_rc_g_fn_gcmds[$1]}"

  [[ -n "$cmd" ]] && echo -n "$cmd" || echo -n "$1"
}

# All of those git aliases, in one place (and not interfering with other commands)
function g() {
  if (( # == 0 )); then
    git help -a
    return $?
  fi

  local cmd="$(_rc_g_fn_gcmd "$1")"
  shift

  _rc_g_fix_gpg_tty
  git "${(@s: :)cmd}" $@
  return $?
}
