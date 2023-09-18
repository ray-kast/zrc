function mime-default-select() {
  if ! _rc_g_has xdg-mime; then
    echo 'Install xdg-mime first.'
    return -1
  fi

  local data_dirs="${XDG_DATA_DIRS:-/usr/local/share/:/usr/share/}"
  local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  local search="$data_home:$data_dirs"

  local d f name_pretty name
  typeset -a entries_pretty
  typeset -A entries
  for d in "${(s.:.)^search}"/applications; do
    [[ -d "$d" ]] || continue

    for f in "$d"/*.desktop; do
      rg -qF 'MimeType' "$f" || continue

      name_pretty="${$(basename "$f")%.desktop}\e[38;5;2m >> $(sed -Ene 's/Name\s*=\s*(.*)\s*/\1/p;T;q 0' "$f")\e[m"
      name="${(S)name_pretty//\\e\[*m}"
      if ! (( $+entries[$name] )); then
        entries_pretty+=("$name_pretty")
        entries[$name]="$f"
      fi
    done
  done

  local selected
  selected="$(echo -n "${(pj:\0:)entries_pretty}" | fzf --read0 --ansi)" || return "$?"
  selected="$entries[$selected]"

  local l t
  typeset -A types
  for l in "${(s:;:)${(f)$(sed -Ene 's/MimeType\s*=\s*(.*)\s*/\1/p' "$selected")}%;}"; do
    types[$l]="$l"
  done

  typeset -a sel_types
  sel_types=("${(@ps:\0:)${$(echo -n "${(kpj:\0:)types}" | fzf --read0 --print0 -m --cycle --bind ctrl-a:select-all)%$'\0'}}") || return "$?"

  xdg-mime default "$selected" "${(@)sel_types}" || return "$?"

  echo "Handler for $#sel_types MIME type(s) updated successfully."
}
