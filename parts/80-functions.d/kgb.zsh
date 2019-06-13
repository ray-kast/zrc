function kgb() {
  local newfile

  newfile="$HISTFILE.new"

  grep -Pva "${(F)@}" "$HISTFILE" >"$newfile"

  git diff "$HISTFILE" "$newfile"

  if [[ $(_rc_g_yn "Apply changes? [y/N]" n) == 'y' ]]; then
    mv "$newfile" "$HISTFILE"
  fi
}
