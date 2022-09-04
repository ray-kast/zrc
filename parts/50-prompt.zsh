_rc_g_prompt_begin

function _rc_g_prompt_ps1() {
  _rc_g_prompt_ps1_line1
  p $'\n'
  _rc_g_prompt_ps1_line2
  p ' '
}

function _rc_g_prompt_ps1_line1() {
  p '%2K%0F'

  local vcs

  [[ -z "$ZRC_NO_GIT_PROMPT" ]] && _rc_g_has git && vcs="$(_rc_g_prompt_ps1_git)"

  [[ -n "$VIRTUAL_ENV" ]] && p " $(basename "$VIRTUAL_ENV") "

  setl 0 3
  p ' %M '
  setl 2 0
  p ' '

  IF L 2; p '%L '; ELSE; FI

  if [[ -n "$vcs" ]]; then
    p "$vcs"
  else
    IF j 1
      setl 4 0
      p ' %j '
      endl 4 f
    ELSE
      endl 2 f
    FI
  fi
}

function _rc_g_prompt_ps1_line2() {
  IF !
    p '%3K%0F %B!!%b '

    IF '?' 0
      endl 3 f
    ELSE
      IF l -101
        setl 0 5
      ELSE
        setl 9 0
      FI
    FI
  ELSE; FI

  IF '?' 0
    IF l -100
      p '%8F %n %2F'
      chevl
    ELSE; FI

    p '%6F '

    IF l -100
      p '%4~'
    ELSE
      p '%2~'
    FI

    p ' %2F'
    chevl
  ELSE
    IF l -100
      p '%0K%5F %n '
      setl 9 0
    ELSE;
      p '%9K%0F'
    FI
    p ' '

    IF l -100
      p '%4~'
    ELSE
      p '%2~'
    FI

    p ' '
    endl 9 f
  FI
}

# TODO: consider porting this to vcs_info
# Characters of note:
#  - U+27A6 detached-head arrow
#  - U+E0A0 (powerline) branch symbol
function _rc_g_prompt_ps1_git() {
  local git_dir ref ref_sym=$'\u27a6' bkgd=6
  typeset -a mode=()
  typeset -A dirty=()

  git_dir="$(git rev-parse --git-dir 2>/dev/null)" || return

  for line in "${(@0)$(git status -z 2>/dev/null)}"; do
    [[ "${line:0:1}" =~ '[^? ]' ]] && dirty[+]=1
    [[ "${line:1:1}" =~ '[^? ]' ]] && dirty[u]=1
    [[ "${line:0:2}" = '??' ]] && dirty[?]=1
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

  setl $bkgd 0
  p " $ref_sym "

  if (( ${#mode} > 0 )); then
    setl 0 5
    p " %B${(j: :)mode}%b "

    setl $bkgd 0
    p ' '
  fi

  p "${ref#refs/heads/} "

  if (( ${#dirty} > 0 )); then
    p "%B${(kj::)dirty}%b "
  fi

  endl $bkgd f
}

function _rc_g_prompt_rps1() {
  p ' %2F'
  chevr

  p '%6F %D{%H:%M}'

  IF l -100
    p ' %2F'
    chevr

    p '%8F %D{%d/%m/%y}'
  ELSE; FI

  IF '?' 0; ELSE
    p ' '
    setr 9 0
    p ' %? '
  FI
}

function _rc_g_prompt_ps2() {
  p '%0K '
  setl 2 0
  p ' '

  IF l -100
    p '%_'
  ELSE
    p '%1_'
  FI

  p ' '
  endl 2 f
  p ' '
}

function _rc_g_prompt_rps2() {
  p ' %2F'
  chevr

  p '%6F '

  IF l -150
    p '%^'
  ELSE
    p '%1^'
  FI
}

function _rc_g_prompt_ps3() {
  p '%2F '
  chevl
  p ' '
}

function _rc_g_prompt_ps4() {
  p '%0F'

  for i in {1..$(print -Pn "%e")}; do p " :"; done

  p ' %e %2F'
  chevl
  p '%6F '
  truncl -100 ..
  p '%x:%I %2F'
  etrunc
  chevl
  p ' '
}

setopt prompt_bang prompt_subst
PS1='%{%f%b%k%}$(_rc_g_prompt_ps1)%{%f%b%k%}'
PS2='%{%f%b%k%}$(_rc_g_prompt_ps2)%{%f%b%k%}'
PS3='%{%f%b%k%}$(_rc_g_prompt_ps3)%{%f%b%k%}'
PS4='%{%f%b%k%}$(_rc_g_prompt_ps4)%{%f%b%k%}'
RPS1='%{%f%b%k%}$(_rc_g_prompt_rps1)%{%f%b%k%}'
RPS2='%{%f%b%k%}$(_rc_g_prompt_rps2)%{%f%b%k%}'

_rc_g_prompt_end
