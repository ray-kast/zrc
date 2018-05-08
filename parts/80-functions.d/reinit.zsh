function reinit() {

  case "${(j: :)@}" in
    "-h"|"--help")
      echo "Usage: reinit [args...]"
      return 0
  esac

  typeset -a args
  args=()

  [[ -o login ]] && args+=(-l)
  [[ -o interactive ]] && args=(-i)

  args=($args $@)

  exec $SHELL ${args[@]}
}
