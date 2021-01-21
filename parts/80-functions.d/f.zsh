function _rc_g_fn_f_fzf() {
  local basedir fname

  basedir="$1"
  [[ -z "$basedir" ]] && basedir=$PWD

  fname="$(fd -uu . --base-directory="$basedir" | fzf || echo '')"
  [[ -n "$fname" ]] && (cd "$basedir"; realpath "$fname")
}

function f() {
  local fname text

  fname="$(_rc_g_fn_f_fzf "$1")"
  [[ -z "$fname" ]] && return 1

  text=''
  [[ "$(file -b "$fname")" =~ '(ASCII|Unicode) text' ]] && text='y'

  if [[ -d "$fname" ]]; then
    ty='directory'
  else
    ty='file'
  fi

  if [[ ! -d "$fname" && -x "$fname" ]]; then
    if [[ "$(_rc_g_yn 'Run executable? [y/N] ' n)" == 'y' ]]; then
      (exec "$fname")
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

function F() {
  local argv0 dname fname text

  if (( # > 0 )); then
    dname="$1"
    shift
  fi

  if (( # > 0 )); then
    argv0="$1"
    shift
  fi

  fname="$(_rc_g_fn_f_fzf "$dname")"
  [[ -z "$fname" ]] && return 1

  text=''
  [[ "$(file -b "$fname")" =~ '(ASCII|Unicode) text' ]] && text='y'

  if [[ -n "$argv0" ]]; then
    (exec "$argv0" "$fname")
  elif [[ -d "$fname" ]]; then
    cd "$fname"
  else
    typeset -a search

    for p in "${(@)path}"; do
      [[ -d "$p" && ! -h "$p" ]] && search+="$p"
    done

    argv0="$(fd -uud1 . "${(@)search}" | fzf || echo '')"
    [[ -z "$argv0" ]] && return 1

    (exec "$argv0" "$fname")
  fi
}
