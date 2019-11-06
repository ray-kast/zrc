function _rc_g_prompt_do_git() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8" _branch _ref _plus _dot _check _bang

  _branch=$'\ue0a0' # U+E0A0 <Private Use> (branch symbol)
  _ref=$'\u27a6'    # U+27A6 HEAVY BLACK CURVED UPWARDS AND RIGHTWARDS ARROW
  _plus=$'\u271a'   # U+271A HEAVY GREEK CROSS
  _dot=$'\u25cf'    # U+25CF BLACK CIRCLE
  _check=$'\u2713'  # U+2713 CHECK MARK

  local repo_path rfsym ref mode msg

  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    ref=$(git symbolic-ref HEAD 2>/dev/null) && rfsym="$_branch" || { rfsym="$_ref"; ref="$(git rev-parse --short HEAD 2>/dev/null)" }
    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    autoload -Uz vcs_info
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr "$_plus"
    zstyle ':vcs_info:*' unstagedstr "$_dot"
    zstyle ':vcs_info:*' formats '%u%c'
    zstyle ':vcs_info:*' actionformats '%u%c'
    vcs_info

    if [[ -n $(git status --porcelain | head -n1) ]]; then
      _rc_g_prompt_set 3 0 r
    else
      _rc_g_prompt_set 6 0 r
    fi

    msg=${vcs_info_msg_0_}

    echo -n " $rfsym ${ref#refs/heads/}${msg:+ $msg}$mode "
  fi
}

function _rc_g_prompt_ps1() {
  RETCODE=$?

  _rc_g_prompt_ps1_line1
  echo
  _rc_g_prompt_ps1_line2
}

function _rc_g_prompt_ps1_line1() {
  _rc_g_prompt_start

  local nested='' job='' vcs='' pad=''

  (( SHLVL > 1 )) && nested=t
  [[ $(jobs -l | head -n1) ]] && job=t
  [[ -z $ZRC_NO_GIT_PROMPT ]] && { _rc_g_has git && git rev-parse >/dev/null 2>/dev/null } && vcs=t

  _rc_g_prompt_set 2 0
  [[ -n $VIRTUAL_ENV ]] && echo -n " $(basename "$VIRTUAL_ENV") "
  _rc_g_prompt_set 0 3 r

  echo -n ' %M '

  if [[ -n $nested || (-z $job && -z $vcs) ]]; then
    _rc_g_prompt_set 2 0 r

    pad=t
  fi

  [[ -n $nested ]] && echo -n " $SHLVL"

  if [[ -n $job ]]; then
    [[ -n $pad ]] && echo -n ' '

    _rc_g_prompt_set 4 0 r
    echo -n " %j"

    pad=t
  fi

  [[ -n $pad ]] && echo -n ' '

  [[ -n $vcs ]] && _rc_g_prompt_do_git

  _rc_g_prompt_set r r r
}

function _rc_g_prompt_ps1_line2() {
  _rc_g_prompt_start

  if (( UID == 0 )); then
    _rc_g_prompt_set 3 0
    echo -n ' ⚡ '
    _rc_g_prompt_set r r r
    echo -n ' '
  fi

  if (( RETCODE == 0 )); then
    _rc_g_prompt_set r 8
    echo -n '%-100(l: %n '
    _rc_g_prompt_chvrn 2 r
    echo -n ':)'
    _rc_g_prompt_set r 6
    echo -n ' %-100(l:%4~:%2~) '
    _rc_g_prompt_chvrn 2 r
  else
    _rc_g_prompt_set 0 5
    echo -n '%-100(l: %n '
    _rc_g_prompt_set 9 0 r
    echo -n ':'
    _rc_g_prompt_set 9 0
    echo -n ') %-100(l:%4~:%2~) '
    _rc_g_prompt_set r r r
  fi

  echo -n ' '
}

function _rc_g_prompt_rps1() {
  RETCODE=$?

  echo -n ' '

  _rc_g_prompt_chvrn 2 l
  _rc_g_prompt_set r 6
  echo -n ' %D{%H:%M}%-100(l: '
  _rc_g_prompt_chvrn 2 l
  _rc_g_prompt_set r 8
  echo -n ' %D{%d/%m/%y}:)'

  if (( RETCODE != 0 )); then
    echo -n ' '
    _rc_g_prompt_set 9 0 l
    echo -n " $RETCODE "
  fi

  _rc_g_prompt_set r r
}

function _rc_g_prompt_ps2() {
  _rc_g_prompt_start

  _rc_g_prompt_set 0 r
  echo -n " "
  _rc_g_prompt_set 2 0 r
  echo -n " %-100(l:%_:%1_) "
  _rc_g_prompt_set r r r
  echo -n " "
}

function _rc_g_prompt_rps2() {
  _rc_g_prompt_start

  echo -n " "
  _rc_g_prompt_set 4 0 l
  echo -n " %-150(l:%^:%1^) "
  _rc_g_prompt_set r r
}

function _rc_g_prompt_ps3() {
  _rc_g_prompt_start

  _rc_g_prompt_set 0 r
  echo -n " "
  _rc_g_prompt_set 2 r r
  echo -n " "
  _rc_g_prompt_set r r r
  echo -n " "
}

function _rc_g_prompt_ps4() {
  _rc_g_prompt_start

  _rc_g_prompt_set 0 8

  for i in {1..$(print -Pn "%e")}; do echo -n " :"; done

  _rc_g_prompt_set 0 4
  echo -n " %-100<..<%x%<<:%I"
  _rc_g_prompt_set 0 3
  echo -n " %1N"
  _rc_g_prompt_set r r r
  echo -n " "
}

setopt prompt_bang prompt_subst
PS1='%{%f%b%k%}$(_rc_g_prompt_ps1)%{%f%b%k%}'
PS2='%{%f%b%k%}$(_rc_g_prompt_ps2)%{%f%b%k%}'
PS3='%{%f%b%k%}$(_rc_g_prompt_ps3)%{%f%b%k%}'
PS4='%{%f%b%k%}$(_rc_g_prompt_ps4)%{%f%b%k%}'
RPS1='%{%f%b%k%}$(_rc_g_prompt_rps1)%{%f%b%k%}'
RPS2='%{%f%b%k%}$(_rc_g_prompt_rps2)%{%f%b%k%}'
