_DOT_BASH_CACHE="$_DOT_BASH_BASEDIR/.bash/cache"

declare -g -A _SOURCED_FILES

function path::is_abs() {
    local file="$1"
    [[ "$file" == "/"* ]]
}

function load_dependency() {
    declare -a _dependencies=(
        "lib/map.lib.bash"
        "lib/array.lib.bash"
    )
    local dependency
    for dependency in "${_dependencies[@]}"; do
        dependency=$(dirname ${BASH_SOURCE[0]})/$dependency
        dependency="$(builtin cd $(dirname $dependency) && builtin pwd)/${dependency##*/}"
        builtin source "$dependency"
        _SOURCED_FILES[$dependency]=$?
    done
}

load_dependency
unset -f load_dependency

# support source function by relative path and files will only be sourced once
function source() {
    local script=$1
    if ! path::is_abs "$script"; then
        script=$(dirname ${BASH_SOURCE[1]})/$script
        script="$(builtin cd $(dirname $script) && builtin pwd)/${script##*/}"
    fi

    if map::contains_key "$script" _SOURCED_FILES; then
        logger::log DEBUG "source $script skipped"
        return "${_SOURCED_FILES[$script]}"
    fi

    builtin source $script
    _SOURCED_FILES[$script]=$?

    return "${_SOURCED_FILES[$script]}"
}

alias .=source

. lib/log.lib.bash

function cleanup() {
    unset -f source
    unalias .
    unset _DOT_BASH_CACHE
    unset _SOURCED_FILES
}

# see cleanup.bash
declare -g -a CLEANUP_HANDLER

CLEANUP_HANDLER+=(cleanup)
