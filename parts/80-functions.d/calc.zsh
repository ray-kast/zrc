function calc() {
  if (( # == 0 )); then
    echo "Usage: calc <expression>"
    return 1
  fi

  local expr
  expr=${(j: :)@}

  expr=$(( $expr ))

  echo "$expr"
}
