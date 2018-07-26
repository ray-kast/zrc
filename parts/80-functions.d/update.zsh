function _rc_g_fn_update_notify() {
  # It appears notify-send may have hung when I was running only a TTY
  (timeout 2s notify-send $@) &!
}

function _rc_g_fn_update_yn() {
  local yn

  while true; do
    echo -n "$1" >&2

    read -k1 yn

    case $yn in
      y|Y)
        echo >&2
        echo y
        return
        ;;
      n|N)
        echo >&2
        echo n
        return
        ;;
      $'\n')
        echo $2
        return
        ;;
      *)
        echo >&2
        ;;
    esac
  done
}

function update() {
  sudo pacman -Sy

  echo ":: Running pacman upgrade..."

  if { pacman -Qu 1>/dev/null 2>/dev/null }; then
    _rc_g_fn_update_notify -i archlinux 'update' 'Starting pacman upgrade...'

    sudo pacman -Su
  else
    echo " there is nothing to do"
  fi

  # TODO: Find a way to suppress this if we're doing nothing
  _rc_g_fn_update_notify -i archlinux 'update' 'Starting AUR upgrade...'

  aurman --aur --show_changes -Syu

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

    echo ':: Use pacman -Rs $(pacman -Qdtq) to remove them'
  fi

  echo ':: Searching for .pacnew files...'

  local pacnews

  pacnews=$(for x in $(pacman -Qql); do if [ -f "$x.pacnew" ]; then echo "$x.pacnew"; fi; done)

  if ! [[ -z $pacnews ]]; then
    echo ":: Resolving .pacnew files..."

    _rc_g_fn_update_notify -i archlinux 'update' 'Resolving .pacnew files...'
  fi

  local new old

  for new in ${(f)pacnews}; do
    old=${new%.pacnew}

    if [[ $(_rc_g_fn_update_yn "View diff for $new? [Y/n] " y) == 'y' ]]; then
      # Using git diff because it can handle colors in less properly
      sudo git diff "$old" "$new"

      if [[ $(_rc_g_fn_update_yn "Replace $old with $new? [y/N] " n) == 'y' ]]; then
        sudo mv $new $old
      else
        if [[ $(_rc_g_fn_update_yn "Delete $new? [y/N] " n) == 'y' ]]; then
          sudo rm $new
        fi
      fi
    fi
  done

  _rc_g_fn_update_notify -i archlinux 'update' 'System update complete.'

  echo ':: Remember to occasionally clean your cache with aurman -Sc'
}
