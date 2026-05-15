# Usage: <print flags> (i.e. P, for use outside prompt strings)
function _rc_g_prompt_begin() {
  alias p="print -${1}n"

  # Usage: IF <cond> [value]; ... ELSE; ... FI
  # NOTE: The ELSE is always required
  alias IF=$'() { p "%${2}(${1}\x01" }'
  alias ELSE=$'p "\x01"'
  alias FI=$'p ")"'

  # Usage: trunc.l <width> <replacement>
  alias trunc.l='() { p "%${1}<${2}<" }'
  # Usage: trunc.r <width> <replacement>
  alias trunc.r='() { p "%${1}>${2}>" }'
  # Usage: trunc.e
  alias trunc.e="p '%<<'"

  # Usage: set.bf <new bg> <new fg>
  alias set.bf='() { p "%K{$1}%F{$2}" }'
  # Usage: set.b <new bg>
  alias set.b='() { p "%K{$1}" }'
  # Usage: set.f <new fg>
  alias set.f='() { p "%F{$1}" }'

  typeset -a bits=(p IF ELSE FI trunc.l trunc.r trunc.e)

  # Create fill left (fl), end left (el), fill right (fr), and lined left and
  # right (l and r) decorators
  # Usage: <alias prefix> <unicode private-use offset>
  function style() {
    local fl=$(( [##16] 0x$2 + 0 )) fr=$(( [##16] 0x$2 + 2 )) \
      l=$(( [##16] 0x$2 + 1 )) r=$(( [##16] 0x$2 + 3 ))

    # Usage: <name>.fl <new bg> <new fg>
    alias $1.fl='() { p "%F{$1}%S\u'$fl'%s%K{$1}%F{$2}" }'
    # Usage: <name>.el <old bg> <format %-flag>
    alias $1.el='() { p "%F{$1}%k\u'$fl'%$2" }'
    # Usage: <name>.fr <new bg> <new fg>
    alias $1.fr='() { p "%F{$1}\u'$fr'%K{$1}%F{$2}" }'
    # Usage: <name>.l
    alias $1.l='p "\u'$l'"'
    # Usage: <name>.r
    alias $1.r='p "\u'$r'"'

    bits+=($1.fl $1.el $1.fr $1.l $1.r)
  }

  # Triangle styl
  style tri e0b0
  # Circle style
  style cir e0b4
  # Valley-sloped line style
  style val e0b8
  # Mountain-sloped line style
  style mtn e0bc

  unfunction style

  typeset -a cmd=(
    unalias "${(@)bits}" \;
    unfunction _rc_g_prompt_end
  )
  functions[_rc_g_prompt_end]=$cmd
}
