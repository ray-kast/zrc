alias b="bundle exec"
alias dh="dirs -v"
alias grep="command grep --color"
alias j="jobs -l"
alias k="kill -9"
alias l="command ls --color -abhlF"
alias lblk="lsblk -oNAME,FSTYPE,UUID,LABEL,MOUNTPOINT,FSSIZE,FSUSED,FSAVAIL"
alias ll="command ls --color -bhlF"
alias ls="command ls --color -bF"
alias pk="pkill -9 -ex"
alias poweroff="shutdown -P 0"
alias reboot="shutdown -r 0"
alias rns="R --no-save"
alias rs="rsync -rcp --progress"
alias rs-del="rsync -rcp --progress --delete"
alias rs-git="rsync -rcp --progress --delete --exclude-from=.gitignore"
alias rw="rlwrap"
alias sr="screen -R"
alias srs="screen -RS"
alias sudo-code="sudo code --user-data-dir=$HOME/.vscode-sudo/"
alias t="tree -pah"

alias -s exe="mono"
alias -s js="node"
alias -s pdf="evince"

if _rc_g_has gio; then
  for x in png jpg gif; do alias -s $x="gio open"; done
fi

if _rc_g_has firefox; then
  for x in svg html; do alias -s $x="firefox"; done
fi
