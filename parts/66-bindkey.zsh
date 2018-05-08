bindkey -e

bindkey " " magic-space
bindkey "^H" backward-kill-word
bindkey "^I" menu-expand-or-complete
bindkey "^[^[" menu-complete
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search
bindkey "^[[1;5A" up-line
bindkey "^[[1;5B" down-line
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[3~" delete-char
bindkey "^[[3;5~" kill-word
bindkey "^[[5~" up-history
bindkey "^[[6~" down-history
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[[H" beginning-of-line
bindkey "^[[E" end-of-line
bindkey "^[[F" end-of-line
bindkey "^[k" describe-key-briefly
bindkey "^]" expand-or-complete
