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

for name in {up,down}-line-or-beginning-search; do
  autoload -U $name
  zle -N $name
done
