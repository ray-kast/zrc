if [[ -t 1 ]] then
  function _rc_i_status() {
    echo -n "\r\x1b[2K[zrc] ${(j: :)@}"
  }

  function _rc_i_status_reset() {
    echo -n "\r\x1b[2K"
  }

  echo -n "[zrc] starting..."
else
  function _rc_i_status() {}

  function _rc_i_status_reset() {}
fi

_rc_i_basedir="$(dirname "$0")"

() {
  local file

  for file in "$_rc_i_basedir"/utils/**/*(on); do
    _rc_i_status util ${${file#$_rc_i_basedir/utils}##/}
    . $file
    unfunction -m '_rc_l_*'
    unset -m '_rc_l_*'
  done

  if [[ -t 1 ]]; then
    () {
      local file

      file="$ZDOTDIR"/.zrc-update

      [[ -n "$(find "$file" -daystart -atime +0 2>/dev/null)" || (! -f "$file") ]] || return

      _rc_i_status "Checking for updates..."

      (
        cd "$HOME"/.zrc

        git fetch -q || exit 1

        [[ "$(git rev-parse HEAD)" != "$(git rev-parse '@{u}')" ]] || {
          _rc_i_status_reset
          echo 'No update available.'
          exit 0
        }

        _rc_i_status_reset

        [[ "$(_rc_g_yn "Update ~/.zrc? [Y/n] " y)" == 'y' ]] || exit 0

        git pull
      ) || { _rc_i_status_reset; echo "WARNING: update check failed"; return }

      touch "$file"
    }
  fi

  for file in "$_rc_i_basedir"/parts/**/*(on); do
    _rc_i_status util ${${file#$_rc_i_basedir/parts}##/}
    . $file
    unfunction -m '_rc_l_*'
    unset -m '_rc_l_*'
  done
}

if [[ -f ~/.zrc-local.zsh ]]; then
  _rc_i_status zrc-local
  . ~/.zrc-local.zsh
fi

_rc_i_status_reset

unfunction -m '_rc_i_*'
unset -m '_rc_i_*'