# Run this script from .zshenv

false && alias _='print' || alias _=':'

_ rxvt # Weird edge-case logic to try to fix rxvt issues with ssh
[[ "$SHLVL" -eq 1 && -n "$TERM" ]] && export TERM="${TERM/rxvt(-unicode|)/xterm}"

_ locale
[[ -v LC_ALL ]] || export LC_ALL="en_US.UTF-8"
[[ -v LC_CTYPE ]] || export LC_CTYPE="en_US.UTF-8"

() {
  if [[ -z "$TERMINAL" ]]; then
    _ terminal
    local term
    for term in kitty1 kitty terminal; do
      if (( $+commands[$term] )) >/dev/null; then
        export TERMINAL="$commands[$term]"
        break
      fi
    done
  fi
}

if [[ "$TERM" = *kitty* || -n "$KITTY_WINDOW_ID" ]]; then
  export ZRC_KITTY_DETECTED="$TERM"
fi

unalias _
