# uv
if (( $+commands[uv] )); then
    eval "$(uv generate-shell-completion zsh)"
fi

if (( $+commands[uvx] )); then
    eval "$(uvx --generate-shell-completion zsh)"
fi
