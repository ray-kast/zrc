#compdef g

function _g() {
  local curcontext=$curcontext state line
  declare -A opt_args
  integer ret=1

  _arguments -C \
    '-C+[run as if git was started in given path]: :_directories' \
    '-b[use $PWD as repository]' \
    '(-p -P)-p[pipe output into a pager]' \
    $'(-p -P)-P[don\'t pipe output into a pager]' \
    '(-): :->command' \
    '(-)*:: :->option-or-argument' && return

  case $state in
    (command)
      local key maxlen sep
      typeset -a cmds disp cmds_disp expl matching

      for key in ${(k)_rc_g_fn_gcmds}; do
        cmds+=("$key")
      done

      _description '' expl ''
      compadd "$expl[@]" -O matching -a cmds

      maxlen=${#${(O)matching//?/.}[1]}

      zstyle -T ":completion:${curcontext}:" verbose && disp=(-ld 'cmds_disp')
      zstyle -s ":completion:${curcontext}:" list-separator sep || sep=--

      (( $#disp )) && set -A cmds_disp ${${(r.COLUMNS-4.)cmds/#%(#m)*/${(r.maxlen.)MATCH} $sep shorthand for "'$_rc_g_fn_gcmds[$MATCH]'"}%% #}

      _alternative "zrc-shorthands:shorthand:compadd ${(e)disp} -a cmds"

      words[1]="git"
      service="git"
      _git && ret=0
      ;;
    (option-or-argument)
      local -a full_cmd
      full_cmd=("${(@s: :)$(_rc_g_fn_gcmd "$words[1]")}")
      words=("git" "${full_cmd[@]}" "${(@)words[2,-1]}")
      (( CURRENT += ${#full_cmd} ))
      service="git"
      _git && ret=0
      ;;
  esac

  return ret
}

_g $@
