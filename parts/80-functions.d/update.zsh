function update() {
  sudo pacman -Sy

  echo ":: Running pacman upgrade..."

  if { pacman -Qu 1>/dev/null 2>/dev/null }; then
    notify-send -i archlinux 'update' 'Starting pacman upgrade...'

    sudo pacman -Su
  else
    echo " there is nothing to do"
  fi

  # TODO: Find a way to suppress this if we're doing nothing
  notify-send -i archlinux 'update' 'Starting AUR upgrade...'

  aurman --aur -Syu

  echo ":: Cleaning up packages..."

  if { pacman -Qmtdq 1>/dev/null 2>/dev/null }; then
    notify-send -i archlinux 'update' 'Cleaning up packages...'

    pacman -Rs $(pacman -Qmtdq)
  else
    echo " there is nothing to do"
  fi

  if { pacman -Qdtq 1>/dev/null 2>/dev/null }; then
    echo ":: The following packages could be cleaned up:"

    pacman -Qdt

    echo ':: Use pacman -Rs $(pacman -Qdtq) to remove them'
  fi

  notify-send -i archlinux 'update' 'System update complete.'

  echo ':: Remember to occasionally clean your cache with aurman -Sc'
}
