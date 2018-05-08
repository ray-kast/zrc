#compdef g

function _g() {
  words[1]="git"

  if (( CURRENT > 2 )); then
    words[2]=$(_rc_g_fn_gcmd "$words[2]")

    _message "'$words[1,2]'"
  else
    typeset -a args cmds cmds_disp expl key matching maxlen sep

    for key in ${(k)_rc_g_fn_gcmds}; do
      alts+=("_rc_sh_$key:$_rc_g_fn_gcmds[$key]:$key")
      cmds+=("$key")
    done

    _description '' expl ''
    compadd "$expl[@]" -O matching -a cmds

    maxlen=${#${(O)matching//?/.}[1]}

    zstyle -T ":completion:${curcontext}:" verbose && disp=(-ld 'cmds_disp')
    zstyle -s ":completion:${curcontext}:" list-separator sep || sep=--

    (( $#disp )) && set -A cmds_disp ${${(r.COLUMNS-4.)cmds/#%(#m)*/${(r.maxlen.)MATCH} $sep shorthand for "'$_rc_g_fn_gcmds[$MATCH]'"}%% #}

    _alternative "zrc-shorthands:shorthand:compadd ${(e)disp} -a cmds"
  fi

  service="git"
  _git
}

_g $@
