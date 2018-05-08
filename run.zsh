if ruby -e 'exit(1) unless STDOUT.tty?'; then
  function _rc_i_status() {
    echo -n "\r\x1b[2K[zrc] ${(j: :)@} "
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

for file in "$_rc_i_basedir"/utils/**/*(on); do
  _rc_i_status util ${${file#$_rc_i_basedir/utils}##/}
  . $file
  unfunction -m '_rc_l_*'
done

for file in "$(dirname "$0")"/parts/**/*(on); do
  _rc_i_status util ${${file#$_rc_i_basedir/parts}##/}
  . $file
  unfunction -m '_rc_l_*'
done

_rc_i_status_reset

unfunction -m '_rc_i_*'