function _rc_l_git() {
  if [[ "$(git config --global user.signingkey)" =~ "^[\s\n]*$" ]]; then
    _rc_i_status_reset
    echo "\x1b[1;38;5;1mNo git signing key found!\x1b[m"

    return 1
  fi

  for cfg in commit push tag; do
    if [[ "$(git config --global $cfg.gpgSign)" != *true* ]]; then
      _rc_i_status_reset
      echo "\x1b[1;38;5;1mGit is not configured to use GPG signing for scope \`$cfg\`!\x1b[m"

      if [[ "$(_rc_g_yn "Fix this? [Y/n] " y)" == 'y' ]]; then
        git config --global --bool "$cfg.gpgSign" true
      fi
    fi
  done
}

if [[ -z "$ZRC_NO_GPG" ]]; then
  _rc_l_git
fi
