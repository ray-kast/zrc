function p() {
  if (( # != 1 )); then
    echo "Usage: p [name]"

    return 1
  fi

  if ! (( ${(P)+1} )); then
    echo "Variable '$1' not set."
    return 128
  fi

  echo ${(P)1}
}