alias a2c="aria2c -x4 -k1M"
alias b="bundle exec"
alias cp="cp -i"
alias dh="dirs -v"
alias fh="f -d~"
alias gg="_rc_g_set_gpg_tty"
alias GG="_rc_g_reset_gpg"
alias grep="command grep --color"
alias j="jobs -l"
alias k="kill -9"
alias kc="kubectl"
alias l="command ls --color -abhlF --group-directories-first"
alias lblk="lsblk -oTYPE,NAME,SIZE,FSTYPE,UUID,LABEL,MODEL,MOUNTPOINT,FSSIZE,FSUSED,FSAVAIL"
alias ll="command ls --color -bhlF --group-directories-first"
alias ls="command ls --color -bF --group-directories-first"
alias mv="mv -i"
alias nn="pnpm"
alias nv="nvim"
alias nvo=$'echo "Don\'t."'
alias nx="pnpx"
alias p="typeset -m --"
alias pf="typeset -mf --"
alias pk="pkill -9 -ex"
alias poweroff="shutdown -P 0"
alias py="python -m"
alias reboot="shutdown -r 0"
alias rm="rm -i"
alias rns="R --no-save"
alias rs="rsync -rcp --progress -z"
alias rs-del="rsync -rcp --progress --delete"
alias rs-git="rsync -rcp --progress --delete --exclude-from=.gitignore"
alias rw="rlwrap"
alias sls="screen -ls"
alias sr="screen -R"
alias srs="screen -RS"
alias sudo-code="sudo code --user-data-dir=$HOME/.vscode-sudo/"
alias t="tree -pah"
alias tn="tmux new-session -A -s"
alias tls="tmux ls"
alias venv="python -m venv"
alias yay='MAKEFLAGS="-j$(nproc)" command yay'
alias zl="zstd --long --ultra -9 -T0 -B0 -vvv"
alias zm="zstd --long --ultra -19 -T0 -B0 -vvv"
alias zs="zstd --long --ultra -22 -T0 -B0 -vvv"

alias :q="exit"
alias :qa="exit"

# display distro info. i always forget the name of this command.
alias rice="neofetch"

alias -s exe="mono"
alias -s js="node"
alias -s pdf="evince"

() {
  local c

  typeset -A clipboards=(
    pbcopy pbcopy
    xclip 'xclip -selection clipboard'
  )

  typeset -a clipboard_order=(pbcopy xclip)

  for c in "${(@)clipboard_order}"; do
    if _rc_g_has "$c"; then
      alias xc="$clipboards[$c]"
      break
    fi
  done
}

() {
  local f

  for f in /opt/esp-idf/export.sh; do
    if [[ -f "$f" ]]; then
      alias espidf=". $f"
      break
    fi
  done
}

() {
  local x

  if [[ -n "$ZRC_KITTY_DETECTED" ]]; then
    alias icat="kitty +kitten icat"
  fi

  typeset -A openers=(
    gio 'gio open'
    open 'open'
    xdg-open 'xdg-open'
  )

  typeset -a opener_order=(xdg-open open gio)

  local open='false'
  for x in "${(@)opener_order}"; do
    if _rc_g_has "$x"; then
      open="$openers[$x]"
      break
    fi
  done

  if [[ "$open" != false ]]; then
    alias open="command $open"

    (( $+aliases[icat] )) || alias icat=open
  fi

  if (( $+aliases[icat] )); then
    for x in png jpg gif; do alias -s $x=icat; done
  fi

  if _rc_g_has firefox; then
    for x in svg html; do alias -s $x="firefox"; done
  fi
}

() {
  typeset -A pairs=(\
    batcat bat
    fdfind fd
    podman docker
  )

  local cmd alt
  for cmd in "${(@k)pairs}"; do
    alt="${pairs[$cmd]}"

    if _rc_g_has "$cmd" && ! _rc_g_has "$alt"; then
      alias "$alt"="$cmd"
    fi
  done
}
