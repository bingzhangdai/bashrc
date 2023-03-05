_DOT_BASH_BASEDIR="$(builtin cd $(dirname ${BASH_SOURCE[1]}) && builtin pwd)"

PATH=$PATH:$_DOT_BASH_BASEDIR/bin

function logger.log() { :; }

# https://stackoverflow.com/questions/5014823/how-to-profile-a-bash-shell-script-slow-startup

# preload some dependencies
source $_DOT_BASH_BASEDIR/lib/path.lib.bash

# support source by relative path and files will only be sourced only once
declare -g -A _SOURCED_FILES
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

declare -g -a CLEANUP_HANDLER
function cleanup() {
    unset -f source
    unalias .
    unset _SOURCED_FILES

    local handle
    for handle in $CLEANUP_HANDLER; do
        if declare -F "$handle" > /dev/null; then
            $handle
            unset -f $handle
        else
            logger.log ERROR "cannot find cleanup callback: '$handle'"
        fi
    done

    unset CLEANUP_HANDLER
    unset -f cleanup
}
