function _rc_g_update_dirlocal() {
  local dir=${PWD%%/##} key value
  while [[ ! (-z "$dir" || -r "$dir/.zrc.local") ]]; do
    dir=${dir%/*}
  done

  unset _rc_g_dl_name

  if [[ ! -r "$dir/.zrc.local" ]]; then
      return
  fi

  while read line; do
    key="${line%%=*}"
    value="${line#*=}"
    case "$key" in
      name) _rc_g_dl_name=$value ;;
    esac
  done <"$dir/.zrc.local"
}

chpwd_functions+=(_rc_g_update_dirlocal)
_rc_g_update_dirlocal
