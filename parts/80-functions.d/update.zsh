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

function _rc_g_fn_update_nvim() {
  _rc_g_has nvim || return 0

  echo ":: Running nvim package upgrade..."

  _rc_g_fn_update_notify 'Starting nvim package upgrade...'

  local basedir dir head origin common

  basedir="$HOME/.config/nvim/pack"

  for dir in "$HOME"/.config/nvim/**/.git(/N); do
    (
      cd "$dir/.."

      if [[ -n $(git status --porcelain | head -n1) ]]; then
        echo "\x1b[1;38;5;1m$(basename "$PWD") has uncommitted changes, refusing update\x1b[m"
        exit 1
      fi

      { timeout 5s git fetch -q } || exit 1

      git rev-parse HEAD | read head
      git rev-parse '@{u}' | read origin

      if [[ "$origin" == "$head" ]]; then
        echo " $(basename "$PWD") up-to-date"
        exit 0
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

  rustup self upgrade-data

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
  _rc_g_fn_update_nvim
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
