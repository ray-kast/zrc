function fcd() {
  cd "$(command f -td -d"${1:-.}")"
}

alias fhc='fcd ~'

function fnv() {
  local cmd="cd ${(D)$(command f -td -d"${1:-$HOME}")}" esc="$cmd"

  [[ "${(q)cmd}" == "$cmd" ]] || esc="${(qq)cmd}"

  nvim -c "$cmd" && print -s nvim -c "$esc"
}
