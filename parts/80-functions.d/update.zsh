function _rc_g_fn_update_notify() {
  # It appears notify-send may have hung when I was running only a TTY
  (timeout 2s notify-send -i archlinux 'update' $1) &!
}

function _rc_g_fn_update_apt() {
  _rc_g_has apt-get || return 0

  echo ":: Running APT upgrade..."

  # TODO: suppress this if no updates are necessary
  _rc_g_fn_update_notify 'Starting APT upgrade...'

  sudo apt-get update && sudo apt-get upgrade

  return 0
}

function _rc_g_fn_update_cabal() {
  _rc_g_has cabal || return 0

  echo ":: Running Cabal update..."

  cabal v2-update

  return 0
}

function _rc_g_fn_update_pacman() {
  _rc_g_has pacman || return 0

  sudo pacman -Sy

  echo ":: Running pacman upgrade..."

  if { pacman -Qu 1>/dev/null 2>/dev/null }; then
    _rc_g_fn_update_notify 'Starting pacman upgrade...'

    sudo pacman -Su
  else
    echo " there is nothing to do"
  fi

  if _rc_g_has yay; then
    # TODO: Find a way to suppress this if we're doing nothing
    _rc_g_fn_update_notify 'Starting AUR upgrade...'

    yay -Syua
  fi

  echo ":: Cleaning up packages..."

  if { pacman -Qmtdq 1>/dev/null 2>/dev/null }; then
    _rc_g_fn_update_notify 'Cleaning up packages...'

    sudo pacman -Rs $(pacman -Qmtdq)
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

    _rc_g_fn_update_notify 'Resolving .pacnew files...'
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

  return 0
}

function _rc_g_fn_update_rustup() {
  _rc_g_has rustup || return 0

  echo ":: Running rustup upgrade..."

  _rc_g_fn_update_notify 'Running rustup update...'

  rustup update

  return 0
}

function _rc_g_fn_update_yarn() {
  _rc_g_has yarn || return 0

  echo ":: Running yarn global upgrade..."

  _rc_g_fn_update_notify 'Running yarn global upgrade...'

  yarn global upgrade

  return 0
}

function update() {
  sudo echo -n || return 1

  # Update system packages first...
  _rc_g_fn_update_apt
  _rc_g_fn_update_pacman

  # ...then run other updaters
  _rc_g_fn_update_cabal
  _rc_g_fn_update_rustup
  _rc_g_fn_update_yarn

  _rc_g_fn_update_notify 'System update complete.'

  echo ':: Remember to occasionally clean your cache with update-clearcache'

  return 0
}



function _rc_g_fn_update-cleanup_apt() {
  _rc_g_has apt-get || return 0

  sudo apt-get autoremove

  return 0
}

function _rc_g_fn_update-cleanup_pacman() {
  _rc_g_has pacman || return 0

  local targets

  targets=$(pacman -Qdtq)

  if ! [[ -z $targets ]]; then
    sudo pacman -Rs ${(f)targets}
  else
    echo ' there is nothing to do'
  fi

  return 0
}

function update-cleanup() {
  sudo echo -n || return 1

  _rc_g_fn_update-cleanup_apt
  _rc_g_fn_update-cleanup_pacman

  return 0
}



function _rc_g_fn_update-clearcache_pacman() {
  _rc_g_has pacman || return 0

  if _rc_g_has yay; then
    yay -Sc
  else
    sudo pacman -Sc
  fi

  return 0
}

function update-clearcache() {
  sudo echo -n || return 1

  _rc_g_fn_update-clearcache_pacman

  return 0
}
