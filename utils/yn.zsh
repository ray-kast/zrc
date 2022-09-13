function _rc_g_yn() {
  local yn

  while :; do
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

