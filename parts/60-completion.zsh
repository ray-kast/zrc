_rc_l_compl_prompt() {
  _rc_g_prompt_start

  _rc_g_prompt_set 2 0
  echo -n " Completing "
  _rc_g_prompt_set 0 3 r
  echo -n " %d "
  _rc_g_prompt_set 2 r r
  echo -n " "
  _rc_g_prompt_set r r r
}

_rc_l_corr_prompt() {
  _rc_g_prompt_start

  _rc_g_prompt_set 2 0
  echo -n " Correcting "
  _rc_g_prompt_set 0 3 r
  echo -n " [%e] "
  _rc_g_prompt_set 2 r r
  echo -n " "
  _rc_g_prompt_set r r r
}

_rc_l_list_prompt() {
  _rc_g_prompt_start

  _rc_g_prompt_set 2 0
  echo -n " Hit TAB for more "
  _rc_g_prompt_set 0 3 r
  echo -n " %l "
  _rc_g_prompt_set 2 0 r
  echo -n " %p "
  _rc_g_prompt_set r r r
}

_rc_l_scroll_prompt() {
  _rc_g_prompt_start

  _rc_g_prompt_set 2 0
  echo -n " Scrolling active "
  _rc_g_prompt_set 0 3 r
  echo -n " %l "
  _rc_g_prompt_set 2 0 r
  echo -n " %p "
  _rc_g_prompt_set r r r
}

fpath=($HOME/.zrc/completion $fpath)

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' completions 1
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' format "$(_rc_l_compl_prompt)"
zstyle ':completion:*' glob 'NUMERIC == 1'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt "$(_rc_l_list_prompt)"
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list '' '+m:{[:lower:]}={[:upper:]}' '+m:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[._-]=** r:|=**' '+l:|=* r:|=*'
zstyle ':completion:*' max-errors 3 numeric
zstyle ':completion:*' menu select=2
zstyle ':completion:*' original true
zstyle ':completion:*' prompt "$(_rc_l_corr_prompt)"
zstyle ':completion:*' select-prompt "$(_rc_l_scroll_prompt)"
zstyle ':completion:*' substitute 'NUMERIC == 2'
zstyle ':completion:*' verbose true

autoload -Uz compinit

export ZCOMPDUMP=$ZDOTDIR/.zcompdump

compinit -d $ZCOMPDUMP
