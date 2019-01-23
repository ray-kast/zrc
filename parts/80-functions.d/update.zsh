function _rc_g_fn_update_notify() {
  # It appears notify-send may have hung when I was running only a TTY
  (timeout 2s notify-send $@) &!
}

function update() {
  sudo sh -c 'pacman -Sy || true' || return 1

  echo ":: Running pacman upgrade..."

  if { pacman -Qu 1>/dev/null 2>/dev/null }; then
    _rc_g_fn_update_notify -i archlinux 'update' 'Starting pacman upgrade...'

    sudo pacman -Su
  else
    echo " there is nothing to do"
  fi

  if { which aurman 1>/dev/null 2>/dev/null }; then
    # TODO: Find a way to suppress this if we're doing nothing
    _rc_g_fn_update_notify -i archlinux 'update' 'Starting AUR upgrade...'

    aurman --aur --show_changes -Su
  fi

  echo ":: Cleaning up packages..."

  if { pacman -Qmtdq 1>/dev/null 2>/dev/null }; then
    _rc_g_fn_update_notify -i archlinux 'update' 'Cleaning up packages...'

    pacman -Rs $(pacman -Qmtdq)
  else
    echo " there is nothing to do"
  fi

  if { pacman -Qdtq 1>/dev/null 2>/dev/null }; then
    echo ":: The following packages could be cleaned up:"

    pacman -Qdt

    echo ':: Use update-cleanup to remove them'
  fi

  echo ':: Searching for .pacnew files...'

  local pacnews

  pacnews=$(find-pacnews)

  if ! [[ -z $pacnews ]]; then
    echo ":: Resolving .pacnew files..."

    _rc_g_fn_update_notify -i archlinux 'update' 'Resolving .pacnew files...'
  fi

  local new old

  for new in ${(f)pacnews}; do
    old=${new%.pacnew}

    if [[ $(_rc_g_yn "View diff for $new? [Y/n] " y) == 'y' ]]; then
      # Using git diff because it can handle colors in less properly
      sudo git diff "$old" "$new"

      if [[ $(_rc_g_yn "Replace $old with $new? [y/N] " n) == 'y' ]]; then
        sudo mv $new $old
      else
        if [[ $(_rc_g_yn "Delete $new? [y/N] " n) == 'y' ]]; then
          sudo rm $new
        fi
      fi
    fi
  done

  if { which rustup 1>/dev/null 2>/dev/null }; then
    _rc_g_fn_update_notify -i archlinux 'update' 'Running rustup update...'

    rustup update
  fi

  _rc_g_fn_update_notify -i archlinux 'update' 'System update complete.'

  echo ':: Remember to occasionally clean your cache with update-clearcache'
}

function update-cleanup() {
  local targets

  targets=$(pacman -Qdtq)

  if ! [[ -z $targets ]]; then
    sudo pacman -Rs ${(f)targets}
  else
    echo ' there is nothing to do'
  fi
}

function update-clearcache() {
  if { which aurman 1>/dev/null 2>/dev/null }; then
    aurman -Sc
  else
    sudo pacman -Sc
  fi
}
