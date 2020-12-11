#compdef umb

function _umb() {
  words[1]="umb"

  typeset -a devs

  for fld in '/dev/disk/by-label/' '/dev/'; do
    for fil in $(command find "$fld" -maxdepth 1); do
      if [[ -n "$(_rc_g_fn_umb_try_blockdev $fil)" ]]; then
        devs+=("${fil#$fld}")
      fi
    done
  done

  _description '' expl ''
  compadd "$expl[@]" -O matching -a devs

  _alternative "umb:block device:compadd ${(e)disp} -a devs"
  service="umb"
}

_umb $@

