function emc() {
  if [[ ! -S "/run/user/$UID/emacs/server" ]]; then
    if { systemctl --user list-unit-files emacs.service >/dev/null 2>/dev/null }; then
      systemctl --user start emacs.service || return $?
    else
      emacs --daemon || return $?
    fi
  fi

  emacsclient $@
}

alias em='emc -nw'
alias emw='emc -c'

function emk() {
  if { systemctl --user list-unit-files emacs.service >/dev/null 2>/dev/null }; then
    systemctl --user stop emacs.service
  else
    emacsclient -e '(save-buffers-kill-emacs)'
  fi
}
