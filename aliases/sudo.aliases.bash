alias sudo='sudo '

# the purpose is to load the same vim configuration files as the current user's
# function sudo() {
#     if [ $# -gt 1 ] && { [ "$1" == 'vi' ] || [ "$1" == 'vim' ]; }; then
#         # `command` will suppress shell function lookups
#         EDITOR="$1" command sudo -e "${@:2}";
#     else
#         command sudo "$@"
#     fi
# }

# function sudo() {
#     # TODO: parse args
#     if [ $# -gt 1 ] && [ "$1" = 'vi' -o "$1" = 'vim' ]; then
#         # `command` will suppress shell function lookups
#         EDITOR="$1" command sudo -e "${@:2}";
#     elif [ $# -gt 1 ] && : $(which $1) && str.starts_with _ "$_DOT_BASH_BASEDIR/bin"; then
#         # command sudo bash -c "PATH=\$PATH:$_DOT_BASH_BASEDIR/bin $@"
#         local command=$(which $1)
#         shift
#         command sudo $command $@
#     else
#         command sudo $@
#     fi
# }
