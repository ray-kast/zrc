function _rc_g_prompt_begin {
  alias p="print -${1}n" # usage: printflags (namely P for non-prompt use)

  # TODO: setn, setk, and setf are present because it appears a zsh 5.8 bug
  #       prevents the use of %#F and %#K
  alias setn='() { p "%K{${1}}%F{${2}}" }' # usage: bg, fg
  alias setk='() { p "%K{${1}}" }' # usage: bg
  alias setf='() { p "%F{${1}}" }' # usage: fg

  alias setl='() { p "%F{${1}}%S\ue0b0%s%K{${1}}%F{${2}}" }' # usage: bg, fg
  alias endl='() { p "%F{${1}}%k\ue0b0%${2}" }' # usage: oldbg, formatspec
  alias setr='() { p "%F{${1}}\ue0b2%K{${1}}%F{${2}}" }' # usage: bg, fg

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
  unalias p \
    setn setk setf \
    setl endl setr \
    chevl chevr \
    IF ELSE FI \
    truncl truncr etrunc
}
