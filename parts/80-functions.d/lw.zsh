function _rc_g_lw_file() {
  ls -lAhd --color "$1" | head -c-1

  if [[ ! -d "$1" && "$(head -c2 "$1")" == "#!" ]]; then
    echo -n " -- runs in $(head -n1 "$1" | tail -c+3)"
  fi

  echo
}

function lw() {
  if (( # != 1 )); then
    echo "Usage: lw <name>"
    return 1
  fi

  typeset -a types
  local i j found ret

  found=0

  if [[ -e "$1" ]]; then
    _rc_g_lw_file "$(realpath "$1")"
    if [[ ! -d "$1" ]]; then file "$1"; fi

    found=1
  fi

  types=("${(@f)$(type -aw $1)}")
  types=("${(@f)$(for i in "$types[@]"; do echo $i; done | uniq)}")

  ret=0

  for i in $types; do
    case "$i" in
      *": alias")
        alias -m "$1"
        ;;
      *": suffix alias")
        echo -n "suffix alias -- "
        alias -sm "${i%:*}"
        ;;
      *": builtin")
        echo "shell builtin '$1'"
        ;;
      *": command")
        if ! grep -q "/" <<<"$1"; then
          for j in ${(s/:/)PATH}; do
            if [[ -f "$j/$1" ]]; then
              _rc_g_lw_file "$j/$1"
            fi
          done
        fi
        ;;
      *": function")
        type -f "$1"
        ;;
      *": none")
        ret=1
        ;;
      *": reserved")
        echo "shell reserved word '$1'"
        ;;
      *)
        echo "unknown type '$it'."
        ;;
    esac
  done

  if (( ret == 0 )); then found=1; fi

  if { whatis "$1" 1>/dev/null 2>/dev/null }; then
    if (( found != 0 )); then echo; fi

    echo "Man pages for '$1':"

    whatis "$1"

    found=1
  fi

  if (( found == 0 )); then return 1; fi
  return 0
}
