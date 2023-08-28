function _rc_l_git() {
  if [[ "$(git config --global user.signingkey)" =~ "^[\s\n]*$" ]]; then
    _rc_i_status_reset
    echo "\x1b[1;38;5;1mNo git signing key found!\x1b[m"

    return 1
  fi

  local cfg
  for cfg in commit tag; do # TODO: add signed push eventually
    if [[ "$(git config --global $cfg.gpgSign)" != *true* ]]; then
      _rc_i_status_reset
      echo "\x1b[1;38;5;1mGit is not configured to use GPG signing for scope \`$cfg\`!\x1b[m"

      if [[ "$(_rc_g_yn "Fix this? [Y/n] " y)" == 'y' ]]; then
        git config --global --bool "$cfg.gpgSign" true
      fi
    fi
  done

  if [[ "$(git config --global push.gpgSign)" == *true* ]]; then
    _rc_i_status_reset
    echo "\x1b[1;38;5;1mSigned pushes are enabled, you probably don't want this.\x1b[m"

    if [[ "$(_rc_g_yn "Fix this? [Y/n] " y)" == 'y' ]]; then
      git config --global --unset-all "push.gpgSign"
    fi
  fi
}

if [[ -z "$ZRC_NO_GPG" ]]; then
  _rc_l_git
fi
