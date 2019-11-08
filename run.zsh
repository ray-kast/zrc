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
  if [[ -t 1 && -v SSH_AGENT_PID ]] && ! { ssh-add -l >/dev/null 2>/dev/null }; then
    _rc_i_status_reset
    ssh-add
  fi

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

        if [[ -n $(git status --porcelain | head -n1) ]]; then
          _rc_i_status_reset
          echo '\x1b[1;38;5;1mYou have uncommitted changes to ~/.zrc, refusing update.\x1b[m'
          exit 1
        fi

        { timeout 5s git fetch -q } || exit 1

        local head origin common

        git rev-parse HEAD | read head
        git rev-parse '@{u}' | read origin

        if [[ "$origin" == "$head" ]]; then
          _rc_i_status_reset
          echo 'No update available.'
          exit 0
        fi

        git merge-base "$head" "$origin" | read common

        if [[ "$head" != "$common" ]]; then
          _rc_i_status_reset

          if [[ "$origin" != "$common" ]]; then
            echo '\x1b[1;38;5;1mYou have local changes to ~/.zrc, refusing update.\x1b[m'
            exit 1
          else
            echo '\x1b[1;38;5;3mYou have local changes to ~/.zrc.\x1b[m'

            [[ "$(_rc_g_yn "Push them? [Y/n] " y)" == 'y' ]] || exit 1

            git push
          fi

          exit 0
        fi

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
