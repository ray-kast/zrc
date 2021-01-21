function f() {
  (( # > 0 )) && pushd "$1"

  fname=$(fd -uu . | fzf || echo '')
  [[ -z "$fname" ]] && return 1

  fname="$(realpath "$fname")"

  (( # > 0 )) && popd >/dev/null 2>/dev/null

  text=''
  [[ "$(file "$fname")" =~ '(ASCII|Unicode) text' ]] && text='y'

  if [[ -d "$fname" ]]; then
    ty='directory'
  else
    ty='file'
  fi

  file "$fname"

  if [[ ! -d "$fname" && -x "$fname" ]]; then
    if [[ "$(_rc_g_yn 'Run executable? [y/N] ' n)" == 'y' ]]; then
      (exec "$(realpath "$fname")")
    elif [[ -n "$text" ]]; then
      nvim "$fname"
    fi
  else
    if [[ -n "$text" ]]; then
      nvim "$fname"
    elif [[ "$(_rc_g_yn "Open $ty? [Y/n] " y)" == 'y' ]]; then
      if _rc_g_has open; then
        open "$fname"
      else
        gio open "$fname"
      fi
    fi
  fi
}
