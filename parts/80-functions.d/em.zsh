function emw() {
  if ! { pgrep -f 'emacs --daemon' 1>/dev/null 2>/dev/null }; then
    emacs --daemon
  fi

  emacsclient $@
}

alias em="emw -nw"
alias emk="emacsclient -e \(save-buffers-kill-emacs\)"
