#!/usr/bin/zsh

function say() {
  [[ -t 2 ]] && echo $'\x1b[1m==> '$@$'\x1b[m' >&2 || echo '==> '$@ >&2
}

function warn() {
  [[ -t 2 ]] && echo $'\x1b[1;38;5;1m=!> '$@$'\x1b[m' >&2 || echo '=!>'$@ >&2
}

function yn() {
  local yn

  while true; do
    echo -n "$1" >&2

    read -k1 yn

    case $yn in
      y|Y)
        echo >&2
        echo y
        return
        ;;
      n|N)
        echo >&2
        echo n
        return
        ;;
      $'\n')
        echo $2
        return
        ;;
      *)
        echo >&2
        ;;
    esac
  done
}

function usage() {
  cat <<EOF >&2
Usage: install.zsh [flags]

Flags:
  -b        Back up files instead of overwriting
  -h        Display this message
  -t [dir]  Use dir as the target directory (defaults to ~/.zsh)
  -u        Same as -h
EOF
}

# ===== Parse flags =====

typeset -a INSTALL_OPTS

INSTALL_OPTS=()

TARGET='$HOME/.zsh'

while getopts "bht:u" opt; do
  case $opt in
    b)
      INSTALL_OPTS+=-b
      BACKUP=1
      ;;
    h|u)
      usage
      exit 0
      ;;
    t)
      TARGET="$OPTARG"
      ;;
    \?)
      usage
      exit 1
      ;;
  esac
done

REAL_TARGET=${(e)TARGET}

# ===== Warn about replaced/overwritten and ignored files =====

if [[ -n $BACKUP ]]; then
  OVERSTR="backed up and replaced"
else
  OVERSTR="overwritten"
fi

if [[ -f "$HOME"/.zshenv ]]; then
  warn "~/.zshenv exists already - it will be $OVERSTR"
fi

if [[ -n $ZDOTDIR ]]; then
  DOTDIR="$ZDOTDIR"
else
  DOTDIR="$HOME"
fi

for f in .zshenv .zshrc; do
  if [[ -f "$REAL_TARGET"/"$f" ]]; then
    warn "$TARGET/$f exists already - it will be $OVERSTR"
  fi
done

if [[ "$ZDOTDIR" != "$HOME/.zsh" ]]; then
  for f in .zshenv .zprofile .zshrc .zlogin; do
    if [[ -f "$DOTDIR"/"$f" ]]; then
      warn "\$ZDOTDIR/$f exists, but will be ignored by zsh after installation"
    fi
  done
fi

# ===== Warn about bad target directories =====

if [[ "$(head -c1 <<<"$TARGET")" == '/' ]]; then
  warn "The target directory you chose appears to be an absolute path"
  say  "If you used \$HOME or ~, you may need to escape them"
fi

# ===== Actually perform the install =====

say "Target directory: '$REAL_TARGET' (as '$TARGET')"

[[ $(yn "Continue with installation? [y/N] " n) == 'y' ]] || exit 1

# NB: I'm making the assumption that the target path doesn't contain U+0001
install "${INSTALL_OPTS[@]}" -Dm755 -T =(sed -e $'s\x01@TARGET@\x01'"$TARGET"$'\x01' install/bootstrap.zsh.in) "$HOME"/.zshenv || exit -1
install "${INSTALL_OPTS[@]}" -Dm755 -t "$REAL_TARGET" install/{.zshenv,.zshrc} || exit -1

say "Installation complete."
