function fzf-history-search() {
  typeset -a results
  results=("${(@f)$(fc -l -1 0 | fzf --scheme=history --query="$BUFFER")}") || return "$?"

  local result="${${results[1]## #}%% *}"
  [[ -n "$result" ]] || return -1

  zle vi-fetch-history -n "$result"
  zle reset-prompt
}

autoload fzf-history-search
zle -N fzf-history-search

function fzf-history-search-accept() {
  zle fzf-history-search || return "$?"
  zle accept-line
}

autoload fzf-history-search-accept
zle -N fzf-history-search-accept

function zle-isearch-update() {
  zle -M "Line $HISTNO"
}

zle -N zle-isearch-update

function zle-isearch-exit() {
  zle -M ""
}

zle -N zle-isearch-exit

export zle_highlight=(
  isearch:fg=2,underline
  region:standout
  special:fg=0,bg=6
  suffix:bold
  paste:fg=0,bg=3
)

() {
  local name
  for name in {up,down}-line-or-beginning-search; do
    autoload -U $name
    zle -N $name
  done
}
