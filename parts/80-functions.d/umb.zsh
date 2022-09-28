function _rc_g_fn_umb_try_blockdev() {
  local p="$(realpath "$1")"

  [[ -b "$p" ]] && echo -n "$p"
}

function _rc_g_fn_umb_blockdev() {
  _rc_g_fn_umb_try_blockdev "$1"
  _rc_g_fn_umb_try_blockdev "/dev/disk/by-label/$1"
  _rc_g_fn_umb_try_blockdev "/dev/$1"
}

function umb() {
  local dev="$(_rc_g_fn_umb_blockdev $@)"
  [[ -z "$dev" ]] && { echo $'\x1b[1;38;5;1mNo block device found.\x1b[m'; return 1 }

  udisksctl mount -b "$dev"
}

function uub() {
  local dev="$(_rc_g_fn_umb_blockdev $@)"
  [[ -z "$dev" ]] && { echo $'\x1b[1;38;5;1mNo block device found.\x1b[m'; return 1 }

  udisksctl unmount -b "$dev"
}
