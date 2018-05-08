# function mk() {
#   if (( # != 4 )); then
#     echo "Usage: mk <file> <mode> <owner> <group>"
#     return 1
#   fi

#   [[ -f "$1" ]] && return [[ "$(stat -c%a "$1")" == "$2" ]] &&
#     [[ "$(stat -c%g "$1")" == "$3" ]] &&
#     [[ "$(stat -c%u "$1")" == "$4" ]];

#   touch "$1" && chmod "$2" && { chown "$3:$4" || sudo chown "$3:$4" } || rm -f "$1"
# }
