function _rc_g_prompt_begin {
  alias p="print -${1}n" # usage: printflags (namely P for non-prompt use)

  alias setl='() { p "%${1}F%S\ue0b0%s%${1}K%${2}F" }' # usage: bg, fg
  alias endl='() { p "%${1}F%k\ue0b0%${2}" }' # usage: oldbg, formatspec
  alias setr='() { p "%${1}F\ue0b2%${1}K%${2}F" }' # usage: bg, fg

  alias chevl="p $'\ue0b1'"
  alias chevr="p $'\ue0b3'"

  alias IF='() { p "%${2}(${1}\`" }' # usage: cond, value
  alias ELSE="p '\`'"
  alias FI="p ')'"

  alias truncl='() { p "%${1}<${2}<" }' # usage: width, str
  alias truncr='() { p "%${1}>${2}>" }' # usage: width, str
  alias etrunc="p '%<<'"
}

function _rc_g_prompt_end() {
  unalias p setl endl setr chevl chevr IF ELSE FI truncl truncr etrunc
}
