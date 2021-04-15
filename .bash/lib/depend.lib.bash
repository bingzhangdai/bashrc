# return true if already processed
function _pragma_once() {
    case $BASH_VERSION in
        ''|[0-3].*) util_log_error "ERROR: Bash 4.0+ required"
        return 1
        ;;
    esac

    declare -g -A _pragma_once_already_seen
    local script="$(cd "$(dirname "${BASH_SOURCE[1]}" )" && pwd)/$(basename "${BASH_SOURCE[1]}")"
    [[ ${_pragma_once_already_seen["$script"]} ]] && return
    _pragma_once_already_seen["$script"]=0

    false
}

alias pragma_once='_pragma_once && return'

function _source_once() {
    declare -g -A _pragma_once_already_seen

    [[ ${_pragma_once_already_seen["$1"]} ]] && return ${_pragma_once_already_seen["$1"]}

    [ -e "$1" ] && builtin source "$1"
    local _exit=$?

    # save exit state
    [[ ${_pragma_once_already_seen["$1"]} ]] && _pragma_once_already_seen["$1"]=$_exit

    return $_exit
}

function include() {
    local script="$(basename ${BASH_SOURCE[1]} | awk "{ sub(/^[^.]*/, \"$1\"); print }")"
    script="$(cd "$(dirname "${BASH_SOURCE[1]}" )" && pwd)/${script}"

    _source_once $script
}

function source() {
    case $1 in
        /*) script=$1 ;;
        *) script="$(cd "$(dirname "$1" )" && pwd)/$(basename "$1")" ;;
    esac

    _source_once $script
}

alias .=source

function pragma_once_cleanup() {
    unset -f _pragma_once
    unset _pragma_once_already_seen
    unalias pragma_once

    unset -f _source_once
    unset -f include
    unset -f source
    unalias .

    unset -f pragma_once_cleanup
}