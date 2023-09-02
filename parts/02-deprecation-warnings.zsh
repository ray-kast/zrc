if [[ -f ~/.zrc-local.zsh ]]; then
  _rc_i_status_reset
  echo "\x1b[1;38;5;1m~/.zrc-local.zsh found, this is no longer supported."

  return 1
fi

