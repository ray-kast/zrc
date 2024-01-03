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

function _rc_g_fn_update_elan() {
  _rc_g_has elan || return 0

  echo ":: Running elan upgrade..."

  _rc_g_fn_update_notify 'Running elan update...'

  elan self update

  elan update

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

  local basedir dir name
  typeset -a dirty

  basedir="$HOME/.config/nvim/pack"

  _rc_g_fix_gpg_tty
  for dir in "$basedir"/**/.git(/N); do
    dir="$(realpath "$dir/..")"

    _rc_g_fix_gpg_tty q
    (
      cd "$dir" || exit 255
      echo -n " $(basename "$dir")"

      { timeout 10s git fetch -q 2>&1 | cat } || exit 255
      (( pipestatus[1] == 0 )) || exit 255

      head="$(git rev-parse HEAD)" || exit 255
      origin="$(git rev-parse '@{u}')" || exit 255

      [[ "$origin" == "$head" ]] || exit 0

      exit 1
    )

    case "$?" in
      0) echo; dirty+=("$dir") ;;
      1) echo " up-to-date" ;;
      130) echo; return 130 ;;
      255) echo " \x1b[1;38;5;1mfailed\x1b[m" ;;
      *) echo " unknown status $?" ;;
    esac
  done

  (( ${#dirty} > 0 )) || return 0

  echo "Packages to be updated:"
  for dir in "${dirty[@]}"; echo " $(basename "$dir")"

  [[ "$(_rc_g_yn 'Proceed? [Y/n] ' y)" == 'y' ]] || return 0

  local any=''
  _rc_g_fix_gpg_tty
  for dir in "${dirty[@]}"; do
    name="$(basename "$dir")"

    _rc_g_fix_gpg_tty q
    (
      cd "$dir"

      head="$(git rev-parse HEAD)"
      origin="$(git rev-parse '@{u}')"

      if [[ -n "$(git status --porcelain | head -n1)" ]]; then
        echo "\x1b[1;38;5;3m$name has uncommitted changes\x1b[m"

        [[ "$(_rc_g_yn "Reset them? [y/N] " n)" == 'y' ]] || exit 1

        { git add --all && git reset --hard "$head" } || exit 1
      fi

      common="$(git merge-base "$head" "$origin")"

      if [[ "$head" != "$common" ]]; then
        if [[ "$origin" != "$common" ]]; then
          echo " \x1b[1;38;5;1m$name has local changes, refusing update\x1b[m"
          exit 1
        else
          echo " \x1b[1;38;5;3m$name has local changes\x1b[m"

          [[ "$(_rc_g_yn "Push them? [y/N] " n)" == 'n' ]] || exit 1

          git push
        fi

        exit 0
      fi

      git merge '@{u}' --ff-only && git gc --aggressive
    ) && any='t' || echo " \x1b[1;38;5;1mfailed to update $name\x1b[m"
  done

  if [[ -n "$any" ]]; then
    for dir in "$basedir"/**/doc(/N); do
      nvim -c "helptags $dir" -c "qa"
    done
  fi

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

  if { pacman -Qu archlinux-keyring 1>/dev/null 2>/dev/null }; then
    _rc_g_fn_update_notify 'Updating pacman keyring...'

    _rc_g_retry -1 'keyring update' sudo pacman -S archlinux-keyring
  fi

  if { pacman -Qu 1>/dev/null 2>/dev/null }; then
    _rc_g_fn_update_notify 'Starting pacman upgrade...'

    _rc_g_retry -1 'pacman' sudo pacman -Su
  else
    echo " there is nothing to do"
  fi

  if _rc_g_has yay; then
    # TODO: Find a way to suppress this if we're doing nothing
    _rc_g_fn_update_notify 'Starting AUR upgrade...'

    MAKEFLAGS="-j$(nproc)" _rc_g_retry -1 'yay' yay -Syua
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

  echo ':: Searching for .pacnew files...'

  local pacnews pacsaves

  pacnews=$(find-pacnews)

  if ! [[ -z $pacnews ]]; then
    echo ":: Resolving .pacnew files..."

    _rc_g_fn_update_notify 'Resolving .pacnew files...'
  fi

  local new old action

  for new in ${(f)pacnews}; do
    old=${new%.pacnew}

    while [[ -e "$new" ]]; do
      print "Found $new" >&2
      print -Pn "%Bd%biff, %Bk%beep, %Br%beplace, %Bp%batch, or do %Bn%bothing: " >&2

      read -k1 action

      case $action in
        d|D)
          echo >&2
          # Using git diff because it can handle colors in less properly
          sudo git diff --no-index -- "$old" "$new"
          ;;
        k|K)
          echo >&2
          sudo rm -i "$new"
          ;;
        r|R)
          echo >&2
          sudo mv -i "$new" "$old"
          ;;
        p|P)
          echo >&2
          sudo -E nvim -d "$new" "$old"
          ;;
        n|N) break ;;
        $'\n') ;;
        *) echo >&2 ;;
      esac
    done
  done

  echo ':: Searching for .pacsave files...'

  pacsaves=$(fd -ig '*.pacsave' / -uu --one-file-system)

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
  _rc_g_fn_update_elan
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

  sudo port reclaim || return $?
  # sudo port uninstall inactive && sudo port uninstall leaves || return $?

  return 0
}

function update-cleanup() {
  sudo echo -n || return 1

  _rc_g_fn_update-cleanup_apt
  _rc_g_fn_update-cleanup_pacman
  _rc_g_fn_update-cleanup_port

  return 0
}
