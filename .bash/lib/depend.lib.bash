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

function source() {
    declare -g -A _pragma_once_already_seen

    local script="$(basename ${BASH_SOURCE[1]} | awk "{ sub(/^[^.]*/, \"$1\"); print }")"
    script="$(cd "$(dirname "${BASH_SOURCE[1]}" )" && pwd)/${script}"

    [[ ${_pragma_once_already_seen["$script"]} ]] && return ${_pragma_once_already_seen["$script"]}

    [ -e "$script" ] && builtin source "$script"
    local _exit=$?

    # save exit state
    [[ ${_pragma_once_already_seen["$script"]} ]] && ${_pragma_once_already_seen["$script"]}=$_exit

    return $_exit
}

alias .=source

function pragma_once_cleanup() {
    unset -f _pragma_once
    unset _pragma_once_already_seen
    unalias pragma_once

    unset -f source
    unalias .

    unset -f pragma_once_cleanup
}