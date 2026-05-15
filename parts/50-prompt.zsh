_rc_g_prompt_begin

function _rc_g_prompt_ps1_line1() {
  set.bf 2 0

  local vcs

  [[ -z "$ZRC_NO_GIT_PROMPT" ]] && (( $+commands[git] )) && vcs="$(_rc_g_prompt_ps1_git)"

  [[ -n "$VIRTUAL_ENV" ]] && p " $(basename "$VIRTUAL_ENV") "

  tri.fl 0 3

  if [[ -n "$_rc_g_dl_name" ]]; then
    p " $_rc_g_dl_name "
    set.bf 0 3
  else
    p ' %M '
  fi

  IF L 2
    tri.fl 2 0
    p ' %L '
  ELSE; FI

  IF j 1
    tri.fl 4 0
    p ' %j '
  ELSE; FI

  if [[ -n "$vcs" ]]; then
    p "$vcs"
  else
    IF j 1
      tri.el 4 f
    ELSE
      IF L 2; ELSE
        tri.fl 2 0
        p ' '
      FI
      tri.el 2 f
    FI
  fi
}

function _rc_l_prompt_ps1_line2() {
  IF !
    set.bf 3 0
    p ' %B!!%b '

    IF '?' 0
      tri.el 3 f
    ELSE
      IF l -101
        tri.fl 0 5
      ELSE
        tri.fl 9 0
      FI
    FI
  ELSE; FI

  IF '?' 0
    IF l -100
      set.f 8
      p ' %n '
      set.f 2
      tri.l
    ELSE; FI

    set.f 6
    p ' '

    IF l -100
      p '%4~'
    ELSE
      p '%2~'
    FI

    p ' '
    set.f 2
    tri.l
  ELSE
    IF l -100
      set.bf 0 5
      p ' %n '
      tri.fl 9 0
    ELSE;
      set.bf 9 0
    FI
    p ' '

    IF l -100
      p '%4~'
    ELSE
      p '%2~'
    FI

    p ' '
    tri.el 9 f
  FI
}

function _rc_l_prompt_ps1() {
  p $'$(_rc_g_prompt_ps1_line1)'
  p $'\n'
  _rc_l_prompt_ps1_line2
  p ' '
}

# TODO: consider porting this to vcs_info
# Characters of note:
#  - U+27A6 detached-head arrow
#  - U+E0A0 (powerline) branch symbol
function _rc_g_prompt_ps1_git() {
  local git_dir ref ref_sym=$'\u27a6' line bkgd=6 skip=''
  typeset -a mode
  typeset -A dirty

  git_dir="$(git rev-parse --git-dir 2>/dev/null)" || return

  for line in "${(@0)$(git status -z 2>/dev/null)}"; do
    [[ -n "$skip" ]] && { skip=''; continue; }
    [[ "${line:0:1}" =~ '[^? ]' ]] && dirty[+]=1
    [[ "${line:1:1}" =~ '[^? ]' ]] && dirty[u]=1
    [[ "${line:0:2}" = '??' ]] && dirty[?]=1

    # Fun new terrible little Git thing I discovered
    [[ "${line:0:1}" =~ 'R|C' ]] && skip='r'
  done

  (( ${#dirty} > 0 )) && bkgd=3

  if ref="$(git symbolic-ref HEAD 2>/dev/null)"; then
    ref_sym=$'\ue0a0'
  else
    ref="$(git rev-parse --short HEAD 2>/dev/null)"
  fi

  [[ -e "$git_dir/BISECT_LOG" ]] && mode+=('B')
  [[ -e "$git_dir/MERGE_HEAD" ]] && mode+=('M')
  [[ -e "$git_dir/rebase" ]] && mode+=('R')
  [[ -e "$git_dir/rebase-apply" ]] && mode+=('RA')
  [[ -e "$git_dir/rebase-merge" ]] && mode+=('RM')

  tri.fl $bkgd 0
  p " $ref_sym "

  if (( ${#mode} > 0 )); then
    tri.fl 0 5
    p " %B${(j: :)mode}%b "

    tri.fl $bkgd 0
    p ' '
  fi

  p "${ref#refs/heads/} "

  if (( ${#dirty} > 0 )); then
    p "%B${(kj::)dirty}%b "
  fi

  tri.el $bkgd f
}

function _rc_l_prompt_rps1() {
  p ' '
  set.f 2
  tri.r

  set.f 6
  p ' %D{%H:%M}'

  IF l -100
    p ' '
    set.f 2
    tri.r

    set.f 8
    p ' %D{%d/%m/%y}'
  ELSE; FI

  IF '?' 0; ELSE
    p ' '
    tri.fr 9 0
    p ' %? '
  FI
}

function _rc_l_prompt_ps2() {
  set.b 0
  p ' '
  tri.fl 2 0
  p ' '

  IF l -100
    p '%_'
  ELSE
    p '%1_'
  FI

  p ' '
  tri.el 2 f
  p ' '
}

function _rc_l_prompt_rps2() {
  p ' '
  set.f 2
  tri.r

  set.f 6
  p ' '

  IF l -150
    p '%^'
  ELSE
    p '%1^'
  FI
}

function _rc_l_prompt_ps3() {
  p ' '
  set.f 2
  tri.l
  p ' '
}

function _rc_l_prompt_ps4() {
  set.f 0

  local i
  for i in {1..$(print -Pn "%e")}; do p " :"; done

  p ' %e '
  set.f 2
  tri.l
  set.f 6
  p ' '
  trunc.l -100 ..
  p '%x:%I '
  trunc.e
  set.f 2
  tri.l
  p ' '
}

setopt prompt_bang prompt_subst
PS1="%{%f%b%k%}$(_rc_l_prompt_ps1)%{%f%b%k%}"
PS2="%{%f%b%k%}$(_rc_l_prompt_ps2)%{%f%b%k%}"
PS3="%{%f%b%k%}$(_rc_l_prompt_ps3)%{%f%b%k%}"
PS4="%{%f%b%k%}$(_rc_l_prompt_ps4)%{%f%b%k%}"
RPS1="%{%f%b%k%}$(_rc_l_prompt_rps1)%{%f%b%k%}"
RPS2="%{%f%b%k%}$(_rc_l_prompt_rps2)%{%f%b%k%}"

_rc_g_prompt_end

