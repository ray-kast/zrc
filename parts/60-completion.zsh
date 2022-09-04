_rc_g_prompt_begin

function _rc_l_compl_prompt() {
  setn 2 0
  p ' Completing '
  setl 0 3
  p ' %d '
  setl 2 0
  p ' '
  endl 2 f
}

function _rc_l_list_prompt() {
  setn 2 0
  p ' Hit TAB for more '
  setl 0 3
  p ' %l '
  setl 2 0
  p ' %p '
  endl 2 f
}

function _rc_l_scroll_prompt() {
  setn 2 0
  p ' Scrolling active '
  setl 0 3
  p ' %l '
  setl 2 0
  p ' %p '
  endl 2 f
}

_rc_g_prompt_end

fpath=($HOME/.zrc/completion $fpath)

zstyle ':completion:*' accept-exact false # Interferes with . for filenames
zstyle ':completion:*' accept-exact-dirs false
zstyle ':completion:*' add-space true
zstyle ':completion:*' ambiguous true
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer \
  _extensions \
  _expand \
  _complete \
  _match \
  _history \
  _ignored \
  _correct \
  _approximate \
  _prefix
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' file-list list
zstyle ':completion:*' file-sort name
zstyle ':completion:*' format "$(_rc_l_compl_prompt)"
zstyle ':completion:*' glob true
zstyle ':completion:*' global true
zstyle ':completion:*' group-name ''
zstyle ':completion:*' group-order local-directories commands builtins functions
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' list-grouped true
zstyle ':completion:*' list-prompt "$(_rc_l_list_prompt)"
zstyle ':completion:*' list-separator '>>'
zstyle ':completion:*' match-original true
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[.]=** e:=*' '+b:=*'
zstyle ':completion:*' max-errors 4 numeric
zstyle ':completion:*' menu select=3
zstyle ':completion:*' original true
zstyle ':completion:*' path-completion true
zstyle ':completion:*' prefix-hidden false
zstyle ':completion:*' range 1000:10 # for history words, try 1000 words 10 at a time
zstyle ':completion:*' remove-all-dups true # also for history words
zstyle ':completion:*' select-prompt "$(_rc_l_scroll_prompt)"
zstyle ':completion:*' select-scroll 0
zstyle ':completion:*' show-ambiguity true
# zstyle ':completion:*' show-completer true
zstyle ':completion:*' substitute true
zstyle ':completion:*' suffix true
zstyle ':completion:*' verbose true

autoload -Uz compinit

export ZCOMPDUMP=$ZDOTDIR/.zcompdump

compinit -d $ZCOMPDUMP
_comp_options+=(globdots)

_rc_g_has kitty && kitty + complete setup zsh | source /dev/stdin
