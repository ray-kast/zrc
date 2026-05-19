function _rc_g_update_dirlocal() {
  # Begin logic for clearing previous state

  unset _rc_g_dl_name
  typeset -Ag _rc_g_dl_aliases _rc_g_dl_orig_aliases

  for k in "${(@k)_rc_g_dl_aliases}"; do
    if [[ "$aliases[$k]" != "$_rc_g_dl_aliases[$k]" ]]; then
      continue
    fi

    if (( $+_rc_g_dl_orig_aliases[$k] )); then
      alias "$k"="$_rc_g_dl_orig_aliases[$k]"
    else
      unalias "$k"
    fi
  done

  # End logic for clearing previous state

  typeset -Ag _rc_g_dl_aliases=() _rc_g_dl_orig_aliases=()

  local dir=${PWD%%/##} key value
  local alias_allow="$ZDOTDIR/.zrc-allowed-dirlocal-aliases"
  typeset -A seen=()

  while :; do
    dir=${dir%%/##}

    if [[ -r "$dir/.zrc.local" ]]; then
      while read line; do
        key=${line%%=*}
        if (( $+seen[$key] )); then
          continue
        fi
        seen[$key]=1

        value=${${line#*=}/\$dir/$dir}
        case "$key" in
          name) _rc_g_dl_name=$value ;;
          alias.*)
            key="${key#alias.}"

            if [[ ! -r "$alias_allow" ]] \
              || ! grep -qF "$key=$value" "$alias_allow"; then
              if [[ "$(_rc_g_yn "Allow alias $key='$value'? [y/N] ")" == y ]]; then
                echo "$key=$value" >>"$alias_allow"
                chmod 600 "$alias_allow"
              else
                continue
              fi
            fi

            if (( $+aliases[$key] )); then
              _rc_g_dl_orig_aliases[$key]=$aliases[$key]
            fi

            _rc_g_dl_aliases[$key]=$value
            alias "$key"="$value"
            ;;
        esac
      done <"$dir/.zrc.local"
    fi

    if [[ -z "${dir#/}" ]]; then
      break
    fi

    dir=${dir%/*}/
  done
}

chpwd_functions+=(_rc_g_update_dirlocal)
_rc_g_update_dirlocal
