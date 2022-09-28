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

function sudo() {
    if [ $# -gt 1 ] && [ "$1" = 'vi' -o "$1" = 'vim' ]; then
        # `command` will suppress shell function lookups
        EDITOR="$1" command sudo -e "${@:2}";
    else
        command sudo "$@"
    fi
}
