# return true if already processed
function _pragma_once() {
    case $BASH_VERSION in
        ''|[0-3].*) util_log_error "ERROR: Bash 4.0+ required"
        return 1
        ;;
    esac

    declare -g -A _pragma_once_already_seen
    [[ ${_pragma_once_already_seen[${BASH_SOURCE[1]}]} ]] && return
    _pragma_once_already_seen[${BASH_SOURCE[1]}]=true

    false
}

alias pragma_once='_pragma_once && return'

function pragma_once_cleanup() {
    unset -f _pragma_once
    unset _pragma_once_already_seen
    unalias pragma_once
    unset -f pragma_once_cleanup
}

function depends_on() {
    local script=$(basename ${BASH_SOURCE[1]} | awk "{ sub(/^[^.]*/, \"$1\"); print }")
    local dir="$(dirname ${BASH_SOURCE[1]})"

    source "$dir/$script"
}

