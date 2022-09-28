declare -g -A _SOURCED_FILES

# preload some dependencies
function load_dependency() {
    declare -a _dependencies=(
        "lib/path.lib.bash"
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

_DOT_BASH_CACHE="$(path::current_path)/cache"

# support source by relative path and files will only be sourced only once
function source() {
    local script=$1
    if ! path::is_abs "$script"; then
        script=$(path::caller_path)/$script
        script="$(builtin cd $(dirname $script) && builtin pwd)/${script##*/}"
    fi

    if [ "${_SOURCED_FILES[$script]+isset}" ]; then
        logger.log DEBUG "source $script skipped"
        return "${_SOURCED_FILES[$script]}"
    fi

    builtin source $script
    _SOURCED_FILES[$script]=$?

    return "${_SOURCED_FILES[$script]}"
}

alias .=source

# load logging library
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
