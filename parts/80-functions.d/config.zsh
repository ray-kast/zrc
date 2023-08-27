{
  typeset -a cmd=(ln -ibsvt '"${XDG_CONFIG_DIR:-$HOME/.config}/nvim"' "'$_rc_i_basedir/config/nvim/init.lua'")
  functions[cfg-install-nvim]=$cmd
}
