#!/usr/bin/env zsh

######## Init

set -e
cd "$(dirname "$0")"

######## Helper functions

if [[ -t 2 ]]; then
  function head() { print -P "%B%12F==>%f $1%b" >&2 }
  function say() { print -P " %B%2F->%f%b $1" >&2 }
  function note() { print -P "  %6F->%f $1" >&2 }
  function warn() { print -P " %B%11F-> WARNING:%f%b $1" >&2 }
  function err() { print -P " %B%9F-> ERROR: $1%f%b" >&2 }
  function ask() { print -Pn "$1" }
else
  function head() { print "==> $1" >&2 }
  function say() { print " -> $1" >&2 }
  function note() { print "  -> $1" >&2 }
  function warn() { print " !> WARNING: $1" >&2 }
  function err() { print " !> ERROR: $1" >&2 }
  function ask() { print -n "$1" | sed 's/%[[:digit:]]*[[:alpha:]]//' >&2 }
fi

function cmd() {
  for c in "${(@)@}"; do
    (( $+commands[$c] )) || continue
    echo "$c"
    return
  done
}

function patch_dest() {
  local vim="$(cmd nvim vim)" cat="$(cmd bat batcat cat)"

  if [[ -z "$vim" ]]; then
    return -1
  fi

  "$vim" -d "$src" "$dest" || return 1
  chmod "$mode" "$dest"

  "$cat" "$dest" || true
  [[ "$(yn "Does this look correct? [y/N] " n)" == y ]] || return 2
}

function put_file() {
  local mode="$1" src="$2" dest="$3" action
  shift 3

  if [[ ! -e "$dest" ]]; then
    install -m"$mode" "$src" "$dest"
    return
  elif [[ ! -f "$dest" ]]; then
    err "Cannot write to '$dest' - not a file"
    return -1
  elif diff -q "$src" "$dest" >/dev/null; then
    note "Contents match - skipping"
    chmod "$mode" "$dest"
    return
  fi

  while :; do
    ask "%Bd%biff, %Bk%beep, %Br%beplace, or %Bp%batch existing file: "

    read -k1 action

    case "$action" in
      d|D)
        echo >&2
        if (( $+commands[git] )); then
          git diff --no-index -- "$dest" "$src" || true
        else
          err "This option requires git to be installed"
        fi
        ;;
      k|K)
        echo >&2
        warn "Skipping install of '$dest'"
        return ;;
      r|R)
        echo >&2
        local tmp="$(mktemp "$dest".bk.XXXXX)"
        mv -f "$dest" "$tmp"
        install -m"$mode" "$src" "$dest"
        rm -i "$tmp" || warn "Removal of temp file '$tmp' failed"
        return ;;
      p|P)
        echo >&2
        while ! patch_dest; do
          case "$?" in
            -1) err "This option requires vim to be installed"; break ;;
            1) err "Patching '$dest' failed"; return 1 ;;
            2) ;;
          esac
        done
        return ;;
      $'\n') ;;
      *) echo >&2 ;;
    esac
  done
}

function unhome() {
  [[ -d "$(dirname "$1")" ]] && 1="$(realpath "$1")"
  echo "${1/$(realpath "$HOME")/\$HOME}"
}

function yn() {
  local yn

  while :; do
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

######## Preliminary checks

head "Checking your environment..."

if [[ "$(realpath "$PWD")" != "$(realpath "$HOME/.zrc")" ]]; then
  err "The zrc repo must be placed in '\$HOME/.zrc'"
  exit -1
fi

######## CLI

function usage() {
  cat <<EOF >&2
Usage: install.zsh [flags]

Flags:
  -h        Display this message
  -t [dir]  Use dir as the target directory
            (default: \$ZDOTDIR or else \$HOME/.zsh)
EOF
}

# Try to infer target from $ZDOTDIR (and by extension previous zrc installs)
pretty_target="${ZDOTDIR:+$(unhome "$ZDOTDIR")}"

# Otherwise default to $HOME/.zsh
pretty_target="${pretty_target:-\$HOME/.zsh}"

while getopts 'ht:' opt; do
  case "$opt" in
    h) usage; exit 0 ;;
    t) pretty_target="$(unhome "$OPTARG")" ;;
    \?) usage; exit 1 ;;
  esac
done

if ! [[ -d "$(dirname "${(e)pretty_target}")" ]]; then
  err "Invalid target directory '$pretty_target'"
  exit -1
fi

target="$(realpath "${(e)pretty_target}")"

######## Installation - write temporary files

# Used in the sed command
if [[ "$pretty_target" == *\x01* ]]; then
  err "Target contained \\x01 byte!"
  exit -1
fi

function drop_temps() {
  rm -f "$env_f" || true
}

function sig_drop_temps() {
  echo >&2
  drop_temps
  exit 1
}

trap drop_temps EXIT
trap sig_drop_temps INT
trap sig_drop_temps TERM
trap sig_drop_temps HUP

env_f="$(mktemp zrc-bootstrap.XXXXX)"
sed -e $'s\x01@TARGET@\x01'"$pretty_target"$'\x01' install/bootstrap.zsh.in >"$env_f"

######## Installation - define manifest

ver_file="$target"/.zrc-ver
version="$(cat VERSION)"

# If, for some deranged reason, /etc/zshenv sets ZDOTDIR, this should catch that
base_dotdir="$(env -i zsh -o norcs -c 'print -n "$ZDOTDIR"')"
base_dotdir="${base_dotdir:-$HOME}"

typeset -A manifest=(
  "$base_dotdir"/.zshenv  "$env_f"
  "$target"/.zshenv       install/.zshenv
  "$target"/.zprofile     install/.zprofile
  "$target"/.zshrc        install/.zshrc
)

######## Installation - check for newer versions

head "Installer version: $version"

if [[ -f "$ver_file" ]]; then
  curr_version="$(cat "$ver_file")"

  if [[ "$curr_version" -gt "$version" ]]; then
    warn "Newer install version '$curr_version' detected!"

    [[ "$(yn 'Continue anyway? [y/N] ' n)" == y ]]
  elif [[ "$curr_version" -eq "$version" ]]; then
    warn "zrc installation already exists - reinstalling"
  fi
fi

######## Installation - confirm config with user

head "Checking install configuration..."
say "Target directory: '$target' (will be formatted as '$pretty_target')"

any_existing=''
for f in "${(@k)manifest}"; do
  if [[ -f "$f" ]]; then
    [[ -n "$any_existing" ]] || warn "The following file(s) already exist:"
    any_existing=t

    note "$f"
  fi
done

if [[ -n "$any_existing" ]]; then
  say "You will be prompted for how to handle each existing file"
fi

curr_dotdir="${ZDOTDIR:-$HOME}"

if [[ "$(realpath "$curr_dotdir")" != "$target" ]]; then
  pretty_curr_dotdir="$(unhome "$curr_dotdir")"
  warn "\$ZDOTDIR will be changed to '$pretty_target' from '$pretty_curr_dotdir'"

  any_existing=''
  for f in \
    .zshenv .zprofile .zshrc .zlogin .zlogout \
    .zcompdump .zcompcache .ztcp_sessions .zkbd .chpwd-recent-dirs \
    .zcalcrc \
    .zsh_history
  do
    [[ -f "$curr_dotdir/$f" ]] || continue

    [[ -n "$any_existing" ]] || warn "The following file(s) will become ignored:"
    any_existing=t

    note "$pretty_curr_dotdir/$f"
  done

  if [[ -n "$any_existing" ]]; then
    say "You may need to manually restore each of these files"
  fi
fi

[[ $(yn 'Continue with installation? [y/N] ' n) == y ]]

######## Installation - install files

head "Installing files..."

[[ -d "$target" ]] && chmod 755 "$target" || install -dm755 "$target"

for dest in "${(@k)manifest}"; do
  src="${manifest[$dest]}"

  say "Installing '$src' as '$dest'..."

  put_file 644 "$src" "$dest"
done

chmod go-rwx . completion # Appease compaudit

######## Installation - update install version

head "Updating installation version..."

echo -n "$version" >"$target"/.zrc-ver

######## Done!

head "zrc successfully installed!"
