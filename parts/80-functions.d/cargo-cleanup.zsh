# Note: you can set CARGO_CLEANUP_ROOT to change the default base directory

function cargo-cleanup() {
  local dir

  if (( # == 1 )); then
    dir="$1"
  elif [[ -v CARGO_CLEANUP_ROOT ]]; then
    dir="$CARGO_CLEANUP_ROOT"
  fi

  if [[ ! -d "$dir" ]]; then
    echo "$dir is not a directory!" >&2
    dir=''
  fi

  if [[ -z "$dir" ]]; then
    cat >&2 <<EOF
Usage: cargo-cleanup [root]
Recursively cleans up Cargo projects contained within root.

Arguments:
  root                The base directory to search in.  Required if no default
                      base directory is set

Environment Variables:
  CARGO_CLEANUP_ROOT  [optional] The default base directory
EOF

    return 1
  fi

  local x d
  for x in "${(@f)$(fd Cargo.toml -uutf "$dir")}"; do
    echo "Cleaning up '$x'..."
    cargo clean --manifest-path "$x" || echo "WARNING: cleanup failed for '$x'"
  done

  for d in "$HOME/.cargo/registry/"{src,cache}; do
    echo "Cleaning up global directory '$d'..."
    rm -rvf "$d"
  done
}
