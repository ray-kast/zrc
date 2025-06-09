() {
  if _rc_g_has mergiraf; then
    local attrs="${$(git config --global core.attributesfile)/#\~/$HOME}"

    if [[ "$attrs" =~ "^[\s\n]*$" ]]; then
      _rc_i_status_reset
      echo "\x1b[1;38;5;1mMergiraf is installed but no attributes file is specified.\x1b[m"
    elif [[ ! -f "$attrs" ]]; then
      _rc_i_status_reset
      echo "\x1b[1;38;5;1mMergiraf is installed but attributes file $attrs does not exist.\x1b[m"
    elif ! diff -q "$attrs" =(mergiraf languages --gitattributes) >/dev/null; then
      _rc_i_status_reset
      echo "\x1b[1;38;5;3mMergiraf gitattributes differs from $attrs.\x1b[m"
    else
      return
    fi

    if [[ "$(_rc_g_yn "Fix this? [Y/n] " y)" == 'y' ]]; then
      mergiraf languages --gitattributes >~/.gitattributes
      git config --global 'core.attributesfile' '~/.gitattributes'
    fi
  fi
}
