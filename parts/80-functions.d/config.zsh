{
  typeset -a cmd=(
    local base='"$1"' dir\;
    dir='"${XDG_CONFIG_DIR:-$HOME/.config}/$base"'\;
    '((' \# \> 0 '))' '&&' shift '||' return 1\;
    mkdir -vp '"$dir"' '&&'
    ln -ibsvt '"$dir"' "'$_rc_i_basedir/config/'"'"$base/${(@)^@}"'
  )
  functions[_rc_g_cfg_install]=$cmd

  cmd=(
    local base='"$1"'\;
    '((' \# \> 0 '))' '&&' shift '||' return 1\;
    ln -ibsvt '"$HOME"' "'$_rc_i_basedir/config/'"'"$base/${(@)^@}"'
  )
  functions[_rc_g_cfg_installdot]=$cmd
}

alias cfg-install-dunst='_rc_g_cfg_install dunst dunstrc'
alias cfg-install-nvim='_rc_g_cfg_install nvim init.lua'
alias cfg-install-picom='_rc_g_cfg_install picom picom.conf'
alias cfg-install-ranger='_rc_g_cfg_install ranger rc.conf rifle.conf scope.sh'
alias cfg-install-rofi='_rc_g_cfg_install rofi config.rasi theme.rasi'
alias cfg-install-tmux='_rc_g_cfg_installdot tmux .tmux.conf'
