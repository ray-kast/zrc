_rc_g_set_gpg_tty() {
  export GPG_TTY="$(tty)"
  gpg-connect-agent updatestartuptty /bye | rg -Fv OK
}
