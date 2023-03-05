alias sudo='sudo '

function sudo() {
    local -a args
    while [[ "$1" == -* ]]; do
        arr.add args "$1"
        shift
    done

    # the purpose is to load the same vim configuration files as the current user's
    if [[ "$1" = 'vi' ]] || [[ "$1" = 'vim' ]]; then
        local EDITOR="$1"
        shift
        if [[ -n "$1" ]] && [[ ! -w "$(dirname $1)" ]]; then
            arr.add args '-e'
            command sudo ${args[@]} $@
        else
            # sudo is not needed
            $EDITOR $@
        fi
        return
    fi

    local exposed="$(expose -q)"
    command sudo ${args[@]} bash -c "${exposed}${exposed:+;} $@"
}
