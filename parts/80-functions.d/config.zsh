{
  typeset -a cmd=(
    local base='"$1"' dir\;
    dir='"${XDG_CONFIG_DIR:-$HOME/.config}/$base"'\;
    '((' \# \> 0 '))' '&&' shift '||' return 1\;
    mkdir -vp '"$dir"' '&&'
    ln -ibsvt '"$dir"' "'$_rc_i_basedir/config/'"'"$base/${(@)^@}"'
  )
  functions[_rc_g_cfg_install]=$cmd
}

alias cfg-install-nvim='_rc_g_cfg_install nvim init.lua'
alias cfg-install-ranger='_rc_g_cfg_install ranger rc.conf rifle.conf scope.sh'
