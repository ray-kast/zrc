function _rc_g_fn_update_notify() {
  _rc_g_has notify_send || return 0

  # It appears notify-send may have hung when I was running only a TTY
  (timeout 2s notify-send -i archlinux 'update' $1) &!
}

function _rc_g_fn_update_apt() {
  _rc_g_has apt-get || return 0

  echo ":: Running APT upgrade..."

  # TODO: suppress this if no updates are necessary
  _rc_g_fn_update_notify 'Starting APT upgrade...'

  sudo apt-get update && sudo apt-get upgrade || return $?

  return 0
}

function _rc_g_fn_update_cabal() {
  _rc_g_has cabal || return 0

  echo ":: Running Cabal update..."

  cabal v2-update

  return 0
}

function _rc_g_fn_update_flatpak() {
  _rc_g_has flatpak || return 0

  echo ":: Running Flatpak update..."

  _rc_g_fn_update_notify 'Starting Flatpak update...'

  flatpak update && flatpak uninstall --unused || return $?

  return 0
}

function _rc_g_fn_update_nvim() {
  _rc_g_has nvim || return 0

  echo ":: Running nvim package upgrade..."

  _rc_g_fn_update_notify 'Starting nvim package upgrade...'

  local basedir dir head origin common

  basedir="$HOME/.config/nvim/pack"

  for dir in "$HOME"/.config/nvim/**/.git(/N); do
    (
      cd "$dir/.."

      { timeout 5s git fetch -q } || exit 1

      git rev-parse HEAD | read head
      git rev-parse '@{u}' | read origin

      if [[ "$origin" == "$head" ]]; then
        echo " $(basename "$PWD") up-to-date"
        exit 0
      fi

      if [[ -n $(git status --porcelain | head -n1) ]]; then
        echo "\x1b[1;38;5;3m$(basename "$PWD") has uncommitted changes\x1b[m"

        [[ "$(_rc_g_yn "Reset them? [y/N] " n)" == 'y' ]] || exit 1

        { git add --all && git reset --hard "$head" } || exit 1
      fi

      git merge-base "$head" "$origin" | read common

      if [[ "$head" != "$common" ]]; then
        if [[ "$origin" != "$common" ]]; then
          echo " \x1b[1;38;5;1m$(basename "$PWD") has local changes, refusing update\x1b[m"
          exit 1
        else
          echo " \x1b[1;38;5;3m$(basename "$PWD") has local changes\x1b[m"

          [[ "$(_rc_g_yn "Push them? [y/N] " n)" == 'n' ]] || exit 1

          git push
        fi

        exit 0
      fi

      [[ "$(_rc_g_yn "Update $(basename "$PWD")? [Y/n] " y)" == 'y' ]] || exit 0

      git pull
    ) || echo " \x1b[1;38;5;1mupdate check failed for $(basename $(realpath "$dir/.."))\x1b[m"
  done

  for dir in "$HOME"/.config/nvim/**/doc(/N); do
    nvim -c "helptags $dir" -c "qa"
  done

  return 0
}

function _rc_g_fn_update_pacman() {
  _rc_g_has pacman || return 0

  if _rc_g_has reflector && [[ "$(_rc_g_yn "Update mirror list? [Y/n] " y)" == 'y' ]]; then
    _rc_g_fn_update_notify 'Updating mirrors...'

    sudo sh -c 'reflector --verbose --sort rate -cUS --score 50 -f 20 --save /etc/pacman.d/mirrorlist && rm -f /etc/pacman.d/mirrorlist.pacnew'
  fi

  sudo pacman -Sy

  echo ":: Running pacman upgrade..."

  local ret
  if { pacman -Qu 1>/dev/null 2>/dev/null }; then
    _rc_g_fn_update_notify 'Starting pacman upgrade...'

    ret=1
    while (( ret != 0 )); do
      sudo pacman -Su
      ret=$?

      if (( ret != 0 )) && [[ "$(_rc_g_yn "pacman failed; retry? [Y/n] " y)" != 'y' ]]; then
        ret=0
      fi
    done
  else
    echo " there is nothing to do"
  fi

  if _rc_g_has yay; then
    # TODO: Find a way to suppress this if we're doing nothing
    _rc_g_fn_update_notify 'Starting AUR upgrade...'

    ret=1
    while (( ret != 0 )); do
      yay -Syua
      ret=$?

      if (( ret != 0 )) && [[ "$(_rc_g_yn "yay failed; retry? [Y/n] " y)" != 'y' ]]; then
        ret=0
      fi
    done
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

    if [[ "$(_rc_g_yn "Remove them now? [Y/n] " y)" == 'y' ]]; then
      _rc_g_fn_update-cleanup_pacman
    else
      echo ':: You can use update-cleanup to remove them later'
    fi
  fi

  echo ":: Cleaning up the cache..."

  sudo paccache -rk3
  sudo paccache -ruk0

  if _rc_g_has yay; then
    yay -Sca --noconfirm
  fi

  echo ':: Searching for .pacnew and .pacsave files...'

  local pacnews pacsaves

  pacnews=$(find-pacnews)
  pacsaves=$(fd -ig '*.pacsave' / -uu --one-file-system)

  if ! [[ -z $pacnews ]]; then
    echo ":: Resolving .pacnew files..."

    _rc_g_fn_update_notify 'Resolving .pacnew files...'
  fi

  local new old

  for new in ${(f)pacnews}; do
    old=${new%.pacnew}

    if [[ $(_rc_g_yn "View diff for $new? [Y/n] " y) == 'y' ]]; then
      # Using git diff because it can handle colors in less properly
      sudo git diff --no-index -- "$old" "$new"

      if [[ $(_rc_g_yn "Replace $old with $new? [y/N] " n) == 'y' ]]; then
        sudo mv "$new" "$old"
      else
        if [[ $(_rc_g_yn "Patch $old? [Y/n] " y) == 'y' ]]; then
          if sudo -E nvim -d "$new" "$old" && [[ $(_rc_g_yn "Delete $new? [Y/n] " y) == 'y' ]]; then
            sudo rm "$new"
          fi
        else
          if [[ $(_rc_g_yn "Delete $new? [y/N] " n) == 'y' ]]; then
            sudo rm "$new"
          fi
        fi
      fi
    fi
  done

  if ! [[ -z $pacsaves ]]; then
    echo ":: Resolving .pacsave files..."

    _rc_g_fn_update_notify 'Resolving .pacsave files...'
  fi

  for new in ${(f)pacsaves}; do
    old=${new%.pacsave}

    if [[ $(_rc_g_yn "View $old? [Y/n] " y) == 'y' ]]; then
      sudo bat "$new" --file-name "$old"

      if [[ $(_rc_g_yn "Delete $new? [y/N] " n) == 'y' ]]; then
        sudo rm "$new"
      fi
    fi
  done

  return 0
}

function _rc_g_fn_update_port() {
  _rc_g_has port || return 0

  echo ":: Running MacPorts upgrade..."

  _rc_g_fn_update_notify 'Starting MacPorts upgrade...'

  sudo port selfupdate && sudo port upgrade outdated || return $?

  if [[ "$(_rc_g_yn "Perform unused port cleanup? [Y/n] " y)" == 'y' ]]; then
    _rc_g_fn_update-cleanup_port
  else
    echo ':: You can use update-cleanup to remove any unused ports later'
  fi

  return 0
}

function _rc_g_fn_update_rustup() {
  _rc_g_has rustup || return 0

  echo ":: Running rustup upgrade..."

  _rc_g_fn_update_notify 'Running rustup update...'

  rustup self upgrade-data

  rustup update

  return 0
}

function _rc_g_fn_update_snap() {
  _rc_g_has snap || return 0

  echo ":: Running snap upgrade..."

  _rc_g_fn_update_notify 'Running snap upgrade...'

  sudo snap refresh

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
  _rc_g_fn_update_port
  _rc_g_fn_update_snap

  # ...then run other updaters
  _rc_g_fn_update_cabal
  _rc_g_fn_update_flatpak
  _rc_g_fn_update_nvim
  _rc_g_fn_update_rustup
  _rc_g_fn_update_yarn

  _rc_g_fn_update_notify 'System update complete.'

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

function _rc_g_fn_update-cleanup_port() {
  _rc_g_has port || return 0

  sudo port uninstall inactive && sudo port uninstall leaves || return $?

  return 0
}

function update-cleanup() {
  sudo echo -n || return 1

  _rc_g_fn_update-cleanup_apt
  _rc_g_fn_update-cleanup_pacman
  _rc_g_fn_update-cleanup_port

  return 0
}
