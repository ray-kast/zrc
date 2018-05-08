function update() {
  pacaur -Syu

  echo ":: Cleaning up packages..."

  if pacaur -Qmtdq; then
    pacaur -Rs $(pacaur -Qmtdq)
  else
    echo " there is nothing to do"
  fi
}
