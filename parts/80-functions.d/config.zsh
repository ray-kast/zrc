{
  typeset -a cmd=(
		local dir='"${XDG_CONFIG_DIR:-$HOME/.config}/nvim"'\;
		mkdir -vp '"$dir"' '&&'
		ln -ibsvt '"$dir"' "'$_rc_i_basedir/config/nvim/init.lua'"
	)
  functions[cfg-install-nvim]=$cmd
}
