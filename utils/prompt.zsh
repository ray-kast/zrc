_rc_g_prompt_colors() {
  echo -n "%{"
  if [[ $1 == "r" ]] || [[ $2 == "r" ]]; then
    echo -n "\e[0m"
  fi
  if [[ $1 != "r" ]]; then
    echo -n "\e[48;5;$1m"
  fi
  if [[ $2 != "r" ]]; then
    echo -n "\e[38;5;$2m"
  fi
  echo -n "%}"

  _RC_L__CURR_BG="$1"
  _RC_L__CURR_FG="$2"
}

_rc_g_prompt_fgcolor() {
  [[ $_RC_L__CURR_FG == $1 ]] && return

  echo -n "%{"
  if [[ $1 == "r" ]]; then
    echo -n "\e[0m"
    if [[ $_RC_L__CURR_BG != "r" ]]; then
      echo -n "\e[48;5;${_RC_L__CURR_BG}m"
    fi
  else
    echo -n "\e[38;5;$1m"
  fi
  echo -n "%}"

  _RC_L__CURR_FG="$1"
}

_rc_g_prompt_bgcolor() {
  [[ $_RC_L__CURR_BG == $1 ]] && return

  echo -n "%{"
  if [[ $1 == "r" ]]; then
    echo -n "\e[0m"
    if [[ $_RC_L__CURR_FG != "r" ]]; then
      echo -n "\e[38;5;${_RC_L__CURR_FG}m"
    fi
  else
    echo -n "\e[48;5;$1m"
  fi
  echo -n "%}"

  _RC_L__CURR_BG="$1"
}

_rc_g_prompt_start() {
  _RC_L_CURR_BG="r"
  _RC_L_CURR_FG="r"
  _RC_L__CURR_BG="r"
  _RC_L__CURR_FG="r"
}

_rc_g_prompt_set() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"

  case $3 in
    l)
      _rc_g_prompt_fgcolor $1
      echo -n $'\ue0b2' # U+E0B2 <Private Use> (left pointing triangle)
      _rc_g_prompt_colors $1 $2
      ;;
    r)
      _rc_g_prompt_colors $1 $_RC_L_CURR_BG
      echo -n $'\ue0b0' # U+E0B0 <Private Use> (right pointing triangle)
      _rc_g_prompt_fgcolor $2
      ;;
    *)
      _rc_g_prompt_colors $1 $2
      ;;
  esac

  _RC_L_CURR_BG="$1"
  _RC_L_CURR_FG="$2"
}

_rc_g_prompg_chvrn() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"

  _rc_g_prompt_fgcolor $1
  case $2 in
    l) echo -n $'\ue0b3' ;; # <Private Use> (thin left pointing chevron)
    r) echo -n $'\ue0b1' ;; # <Private Use> (thin right pointing chevron)
  esac
  _rc_g_prompt_fgcolor $_RC_L_CURR_FG
}
