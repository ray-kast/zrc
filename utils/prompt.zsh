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
  if [[ $3 == "l" ]]; then
    _rc_g_prompt_fgcolor $1
    echo -n $_RC_L_LTRI
    _rc_g_prompt_colors $1 $2
  elif [[ $3 == "r" ]]; then
    _rc_g_prompt_colors $1 $_RC_L_CURR_BG
    echo -n $_RC_L_RTRI
    _rc_g_prompt_fgcolor $2
  else
    _rc_g_prompt_colors $1 $2
  fi

  _RC_L_CURR_BG="$1"
  _RC_L_CURR_FG="$2"
}

_rc_g_prompg_chvrn() {
  _rc_g_prompt_fgcolor $1
  if [[ $2 == "l" ]]; then
    echo -n $_RC_L_LCHE
  elif [[ $2 == "r" ]]; then
    echo -n $_RC_L_RCHE
  fi
  _rc_g_prompt_fgcolor $_RC_L_CURR_FG
}
