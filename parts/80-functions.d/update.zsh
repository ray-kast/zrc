function update() {
  sudo pacman -Sy

  echo ":: Running pacman upgrade..."

  if { pacman -Qu 1>/dev/null 2>/dev/null }; then
    notify-send -i archlinux 'update' 'Starting pacman upgrade...'

    sudo pacman -Su
  else
    echo " there is nothing to do"
  fi

  echo ":: Running AUR upgrade..."

  if { pacaur -k 1>/dev/null 2>/dev/null }; then
    notify-send -i archlinux 'update' 'Starting AUR upgrade...'

    pacaur -Sau
  else
    echo " there is nothing to do"
  fi

  echo ":: Cleaning up packages..."

  if { pacaur -Qmtdq 1>/dev/null 2>/dev/null }; then
    notify-send -i archlinux 'update' 'Cleaning up packages...'

    pacaur -Rs $(pacaur -Qmtdq)
  else
    echo " there is nothing to do"
  fi

  if { pacaur -Qdtq 1>/dev/null 2>/dev/null }; then
    echo ":: The following packages could be cleaned up:"

    pacaur -Qdt
  fi

  notify-send -i archlinux 'update' 'System update complete.'
}
