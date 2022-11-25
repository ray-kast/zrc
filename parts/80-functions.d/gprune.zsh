function gprune() {
  g fetch -ap || return $?

  local ref parsed any head

  head="$(git rev-parse --abbrev-ref HEAD)"

  for ref in "${(@f)$(git for-each-ref --format '%(refname:short)' 'refs/heads/**/*')}"; do
    [[ "$ref" != "$head" ]] || continue
    ! git rev-parse --verify -q "$ref@{u}" >/dev/null || continue

    any=t

    [[ "$(_rc_g_yn "Delete $ref? [y/N] " n)" == y ]] || continue
    _rc_g_retry -1 'git-branch' git branch -D "$ref"
  done

  [[ -n "$any" ]] || echo "Nothing to do."
}
