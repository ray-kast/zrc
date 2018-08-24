alias bigtext="figlet" # because 'figlet' is hard to remember
alias dh="dirs -v"
alias grep="command grep --color"
alias j="jobs -l"
alias k="kill -9"
alias l="command ls --color -abhlF"
alias lblk="lsblk -oNAME,FSTYPE,UUID,LABEL,MOUNTPOINT"
alias ll="command ls --color -bhlF"
alias ls="command ls --color -bF"
alias pk="pkill -9 -e"
alias poweroff="shutdown -P 0"
alias psc="ps xawf -eo pid,user,cgroup,args"
alias reboot="shutdown -r 0"
alias rns="R --no-save"
alias rw="rlwrap"
alias sudo-code="sudo code --user-data-dir=$HOME/.vscode-sudo/"
alias t="tree -pah"

alias '#'="calc"

alias -s exe="mono"
alias -s js="node"
alias -s pdf="evince"

if { which gio 1>/dev/null 2>/dev/null }; then
  for x in png jpg gif; do alias -s $x="gio open"; done
fi

if { which firefox 1>/dev/null 2>/dev/null }; then
  for x in svg html; do alias -s $x="firefox"; done
fi
