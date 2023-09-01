function fcd() {
  local dir
  dir="$(command f -td -d"${1:-.}")" && cd "$dir"
}

alias fhc='fcd ~'

function fnv() {
  local cmd esc
  cmd="cd ${(D)$(command f -td -d"${1:-$HOME}")}" || return "$?"

  [[ "${(q)cmd}" == "$cmd" ]] && esc="$cmd" || esc="${(qq)cmd}"

  echo -en $'\e]2;'"nvim -c $esc"$'\a' && \
    nvim -c "$cmd" && \
    print -s nvim -c "$esc"
}
