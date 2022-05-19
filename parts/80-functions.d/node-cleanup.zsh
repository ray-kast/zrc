# Note: you can set NODE_CLEANUP_ROOT to change the default base directory

function node-cleanup() {
  local dir

  if (( # == 1 )); then
    dir="$1"
  elif [[ -v NODE_CLEANUP_ROOT ]]; then
    dir="$NODE_CLEANUP_ROOT"
  fi

  if [[ ! -d "$dir" ]]; then
    cat >&2 <<EOF
Usage: node-cleanup [root]
Recursively cleans up node_modules directories within root.

Arguments:
  root                The base directory to search in.  Required if no default
                      base directory is set

Environment Variables:
  NODE_CLEANUP_ROOT   [optional] The default base directory
EOF

    return 1
  fi

  echo 'Searching for package.json manifests...'

  local x d m
  typeset -a targets
  fd -g package.json -tf "$dir" | while read x; do
    d="$(dirname "$x")"
    m="$d/node_modules"
    [[ "$d" != *node_modules* && -d "$m" ]] || continue

    targets+=("$m")
  done

  echo 'Searching for NextJS build directories...'

  fd -guu .next -td "$dir" | while read x; do
    targets+=("$x")
  done

  echo 'The following targets will be removed:'
  for x in  "${targets[@]}"; do
    echo " - $x"
  done

  [[ "$(_rc_g_yn 'Proceed? [y/N] ' n)" == y ]] || return -1

  for x in "${targets[@]}"; do
    rm -rvf "$x"
  done
}
