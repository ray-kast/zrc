{
  typeset -a cmd=(
    local dir='"${XDG_CONFIG_DIR:-$HOME/.config}/nvim"'\;
    mkdir -vp '"$dir"' '&&'
    ln -ibsvt '"$dir"' "'$_rc_i_basedir/config/nvim/init.lua'"
  )
  functions[cfg-install-nvim]=$cmd

  cmd=(
    local dir='"${XDG_CONFIG_DIR:-$HOME/.config}/ranger"'\;
    mkdir -vp '"$dir"' '&&'
    ln -ibsvt '"$dir"' "'$_rc_i_basedir/config/ranger/'{rc.conf,rifle.conf,scope.sh}"
  )
  functions[cfg-install-ranger]=$cmd
}
