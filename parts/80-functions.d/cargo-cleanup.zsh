# Note: you can set CARGO_CLEANUP_ROOT to change the default base directory

function cargo-cleanup() {
  local dir

  if (( # == 1 )); then
    dir="$1"
  elif [[ -n "$CARGO_CLEANUP_ROOT" ]]; then
    dir="$CARGO_CLEANUP_ROOT"
  fi

  if [[ -z "$dir" ]]; then
    cat >2 <<EOF
Usage: cargo-cleanup [root]
Recursively cleans up Cargo projects contained within root.

Arguments:
  root                The base directory to search in.  Required if no default
                      base directory is set

Environment Variables:
  CARGO_CLEANUP_ROOT  [optional] The default base directory
EOF

    exit 1
  fi

  for x in "$dir"/**/Cargo.toml; do
    echo "Cleaning up '$x'..."
    (cd $(dirname $x); cargo clean) || echo "WARNING: cleanup failed for '$x'"
  done
}