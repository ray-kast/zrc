# function aur() {
#   local oldpwd
#   oldpwd="$PWD"

#   if (( # == 0 )); then
#     echo "Usage: aur <packages...>"
#     return 1
#   fi

#   cd "$HOME/AUR"

#   [[ -d ".tmp" ]] || mkdir .tmp

#   for p in $@; do
#     echo "\x1b[1m[AUR]\x1b[0;38;5;2m installing package '$p'...\x1b[0m"

#     if [[ -d "$p" ]]; then
#       echo "Folder '$p' already exists."
#       echo -n "Replace it? [Y/n] "
#       case $(read -sEk1) in
#         n|N)
#           echo "n"
#           continue
#           ;;
#         *)
#           echo "y"
#           rm -rf -- "$p"
#           ;;
#       esac
#     fi

#     rm -rf -- ".tmp/$p"

#     git clone "https://aur.archlinux.org/$p.git" ".tmp/$p"

#     local success

#     cd ".tmp/$p"

#     [[ -n $(git ls-files) ]] && success=true || success=false

#     cd ../..

#     if $success; then
#       mv ".tmp/$p" "$p"
#       cd "$p"

#       echo "\x1b[1m[AUR]\x1b[0;38;5;2m opening PKGBUILD for '$p'...\x1b[0m"

#       vim -c "set nomodifiable readonly | map q :q!<CR> | map <Up> <C-Y> | map <Down> <C-E>" PKGBUILD

#       echo "\x1b[1m[AUR]\x1b[0;38;5;2m building '$p'...\x1b[0m"

#       makepkg -si

#       cd ..

#       echo "\x1b[1m[AUR]\x1b[0;38;5;3m done!\x1b[0m"
#     else
#       echo "\x1b[1;38;5;1m[AUR]\x1b[0;38;5;1m package '$p' does not appear to exist\x1b[0m"

#       rm -rf -- ".tmp/$p"
#     fi
#   done

#   cd "$oldpwd"
# }
