_RC_L_CURR_BG=""
_RC_L_CURR_FG=""
_RC_L__CURR_BG=""
_RC_L__CURR_FG=""
() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  _RC_L_RTRI="\ue0b0"  # U+E0B0 <Private Use> (right pointing triangle)
  _RC_L_RCHE="\ue0b1"  # U+E0B1 <Private Use> (thin right pointing chevron)
  _RC_L_LTRI="\ue0b2"  # U+E0B2 <Private Use> (left pointing triangle)
  _RC_L_LCHE="\ue0b3"  # U+E0B3 <Private Use> (thin left pointing chevron)
  _RC_L_GITBR="\ue0a0" # U+E0A0 <Private Use> (branch symbol)
  _RC_L_GITRF="\u27a6" # U+27A6 HEAVY BLACK CURVED UPWARDS AND RIGHTWARDS ARROW
  _RC_L_GITPL="\u271a" # U+271A HEAVY GREEK CROSS
  _RC_L_GITDT="\u25cf" # U+25CF BLACK CIRCLE
  _RC_L_GITCK="\u2713" # U+2713 CHECK MARK
  _RC_L_GITXM="\u2757" # U+2757 HEAVY EXCLAMATION MARK SYMBOL
}

_rc_g_prompt_do_git() {
  (( $+commands[git] )) || return

  local repo_path rfsym ref mode msg

  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    ref=$(git symbolic-ref HEAD 2>/dev/null) && rfsym="$_RC_L_GITBR" || { rfsym="$_RC_L_GITRF"; ref="$(git rev-parse --short HEAD 2>/dev/null)" }
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
    zstyle ':vcs_info:*' stagedstr "$_RC_L_GITPL"
    zstyle ':vcs_info:*' unstagedstr "$_RC_L_GITDT"
    zstyle ':vcs_info:*' formats '%u%c'
    zstyle ':vcs_info:*' actionformats '%u%c'
    vcs_info

    if [[ -n $(git status --porcelain | head -n1) ]]; then
      _rc_g_prompt_set 3 0 r
    else
      if [[ $1 -ne 0 ]]; then
        _rc_g_prompt_set 2 0 r
      else
        _rc_g_prompt_set 6 0 r
      fi
    fi

    msg=${vcs_info_msg_0_%%}

    echo -n " %-100(l@$rfsym ${ref#refs/heads/}${msg:+ $msg}$mode@$rfsym"
    [[ ${ref#refs/heads/} == "master" ]] && echo -n " $_RC_L_GITXM" || echo -n " "
    echo -n "${msg:-$_RC_L_GITCK}$mode) "
  fi
}

_rc_g_prompt_ps1() {
  RETCODE=$?

  _rc_g_prompt_start

  local nest root

  [[ $SHLVL -gt 1 ]] && nest=t || nest=''
  [[ $UID -eq 0 ]] && root=t || root=''

  if [[ -n $nest || -n $root ]]; then
    _rc_g_prompt_set 3 0

    if [[ -n $root ]]; then
      echo -n " ⚡"
    fi

    if [[ -n $nest ]]; then
      echo -n " $SHLVL"
    fi

    echo -n " "

    _rc_g_prompt_set 0 r r
  fi

  if [[ $RETCODE -ne 0 ]]; then
    _rc_g_prompt_set 0 5
  else
    _rc_g_prompt_set 0 2
  fi
  echo -n "%-100(l/ %-100<..<%M%<< "
  [[ $RETCODE -ne 0 ]] && _rc_g_prompg_chvrn 6 r || _rc_g_prompg_chvrn 1 r
  [[ $RETCODE -ne 0 ]] && _rc_g_prompt_set 0 13 || _rc_g_prompt_set 0 3
  echo -n " %n "
  if [[ $RETCODE -ne 0 ]]; then
    _rc_g_prompt_set 9 0 r
  else
    _rc_g_prompt_set 2 0 r
  fi
  echo -n "/"
  if [[ $RETCODE -ne 0 ]]; then
    _rc_g_prompt_set 9 0
  else
    _rc_g_prompt_set 2 0
  fi
  echo -n ") %-100(l/%~/%2~) "

  [[ -z $ZRC_NO_GIT_PROMPT ]] && _rc_g_prompt_do_git $RETCODE
  _rc_g_prompt_set r r r
  echo -n " "
}

_rc_g_prompt_rps1() {
  RETCODE=$?

  _rc_g_prompt_start

  echo -n " "
  _rc_g_prompt_set 2 0 l
  echo -n " %D{%H:%M} %-100(l:"
  _rc_g_prompg_chvrn 0 l
  echo -n " %D{%d/%m/%y} :)"

  if [[ $(jobs -l | head -n1 | wc -l) -gt 0 ]]; then
    _rc_g_prompt_set 4 0 l
    echo -n " %-100(l:%j :)"
  fi

  if [[ $RETCODE -ne 0 ]]; then
    _rc_g_prompt_set 9 0 l
    echo -n " $RETCODE "
  fi

  _rc_g_prompt_set r r
}

_rc_g_prompt_ps2() {
  _rc_g_prompt_start

  _rc_g_prompt_set 0 r
  echo -n " "
  _rc_g_prompt_set 2 0 r
  echo -n " %-100(l:%_:%1_) "
  _rc_g_prompt_set r r r
  echo -n " "
}

_rc_g_prompt_rps2() {
  _rc_g_prompt_start

  echo -n " "
  _rc_g_prompt_set 4 0 l
  echo -n " %-150(l:%^:%1^) "
  _rc_g_prompt_set r r
}

_rc_g_prompt_ps3() {
  _rc_g_prompt_start

  _rc_g_prompt_set 0 r
  echo -n " "
  _rc_g_prompt_set 2 r r
  echo -n " "
  _rc_g_prompt_set r r r
  echo -n " "
}

_rc_g_prompt_ps4() {
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
