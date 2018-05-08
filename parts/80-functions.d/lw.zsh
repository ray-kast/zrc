function _rc_g_lw_file() {
  ls -lAhd --color "$1" | head -c-1

  if [[ "$(head -c2 "$1")" == "#!" ]]; then
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
  local it
  types=("${(@f)$(type -aw $1)}")

  local i
  for i in $types; do
    it=$(sed -re 's/^\s*'"$(sed -re 's/([]\[\(\)\/])/\\\1/g' <<<"$1")"'\s*:\s*(.*)\s*$/\1/g' <<<"$i")

    case "$it" in
      "alias")
        alias -m "$1"
        ;;
      "builtin")
        echo "shell builtin '$1'"
        ;;
      "command")
        if grep -q "/" <<<"$1"; then
          _rc_g_lw_file "$1"
        else
          local j
          for j in ${(s/:/)PATH}; do
            if [[ -f "$j/$1" ]]; then
              _rc_g_lw_file "$j/$1"
            fi
          done
        fi
        ;;
      "function")
        type -f "$1"
        ;;
      "none")
        return 1
        ;;
      "reserved")
        echo "shell reserved word '$1'"
        ;;
      *)
        echo "unknown type '$it'."
        ;;
    esac
  done
}
