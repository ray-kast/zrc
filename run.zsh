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
_rc_i_verfile="$ZDOTDIR/.zrc-ver"

function reinstall() {
  local file="$_rc_i_verfile" curr="$_rc_i_basedir/VERSION"

  _rc_i_status zrc-ver

  [[ ! -f "$file" || "$(cat "$file")" -lt "$(cat "$curr")" ]] || return 0

  _rc_i_status_reset
  echo $'\x1b[1;38;5;9mzrc installation out of date!\x1b[m'

  [[ "$(_rc_g_yn 'Update installation? [y/N] ' n)" == 'y' ]] || return 0

  "$_rc_i_basedir"/install.zsh || {
    echo $'\x1b[1;38;5;3mInstaller failed.\x1b[m'
    return 1
  }

  echo $'\x1b[1;38;5;2mInstallation succeeded.  A restart may be required.\x1b[m'
}

() {
  local file

  for file in "$_rc_i_basedir"/utils/**/*(on); do
    _rc_i_status util ${${file#$_rc_i_basedir/utils}##/}
    . $file
    unfunction -m '_rc_l_*'
    unset -m '_rc_l_*'
  done

  reinstall

  if [[ -t 1 ]] && (( $+commands[ssh-add] )); then
    . "$_rc_i_basedir"/gpg.zsh
    if (( $+_rc_g_gpg[found] )); then
      _rc_i_status_reset
      echo "Using gpg-agent for SSH keys"

      if (( $+_rc_g_gpg[already-running] )); then
        echo $'\x1b[1;38;5;3mDetached existing ssh-agent!\x1b[m'
      fi

      _rc_g_fix_gpg_tty
    elif (( $+_rc_g_gpg[enabled] && ! $+_rc_g_gpg[already-running] )); then
      _rc_i_status_reset
      echo "No GPG socket found!"
    fi

    if (( $+commands[ssh-agent] )) && ! [[ -v SSH_AGENT_PID ]]; then
      _rc_i_status_reset
      echo "No SSH agent found! Exec'ing ssh-agent..."
      exec ssh-agent $SHELL
    fi

    if ! { ssh-add -l >/dev/null 2>/dev/null }; then
      _rc_i_status_reset

      for i in {1..3}; do
        ssh-add && break
      done
    fi

    () {
      local file

      file="$ZDOTDIR"/.zrc-update
      [[ -f "$file" ]] && rm -rf "$file" # old location

      file="$_rc_i_verfile"

      [[ -n "$(find "$file" -daystart -atime +0 2>/dev/null)" || (! -f "$file") ]] || return

      _rc_i_status "Checking for updates..."

      local lock="$file.lck"
      if [[ -f "$lock" ]]; then
        _rc_i_status_reset
        echo 'WARNING: Update lockfile exists, skipping update check'
        return
      fi

      echo -n >"$lock" || {
        _rc_i_status_reset
        echo 'WARNING: Update check failed, unable to lock'
        return
      }

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

        git pull || exit 1
        reinstall
      ) || { _rc_i_status_reset; echo "WARNING: update check failed"; return }

      touch "$file"
      rm -rf "$lock"
    }
  fi

  for file in "$_rc_i_basedir"/parts/**/*(on); do
    _rc_i_status util ${${file#$_rc_i_basedir/parts}##/}
    . $file
    unfunction -m '_rc_l_*'
    unset -m '_rc_l_*'
  done
}

_rc_i_status_reset

unfunction -m '_rc_i_*'
unset -m '_rc_i_*'
