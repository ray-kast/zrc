function big-dft() {
  local graph_pow=22 err_pow=3

  if [[ "$1" == <-> ]]; then
    graph_pow=$1
    shift
  fi

  if [[ "$1" == <-> ]]; then
    err_pow=$1
    shift
  fi

  DFT_GRAPH_LIMIT=$(( 1 << graph_pow )) DFT_PARSE_ERROR_LIMIT=$(( 1 << err_pow )) "$@"
}
