export _DOT_BASH_CACHE="${_DOT_BASH_BASEDIR}/.bash/cache"

# save already sourced scripts
declare -g -A _pragma_once_already_seen

# return true if already processed
function _pragma_once() {
    local script="${BASH_SOURCE[1]}"
    if [ "$script" = "${script#/}" ]; then
        script="$(builtin cd "$(dirname "$script" )" && pwd)/${script##*/}"
    fi

    [[ ${_pragma_once_already_seen["$script"]} ]] && return
    _pragma_once_already_seen["$script"]=0

    false
}

alias pragma_once='_pragma_once && return'

function source_impl() {
    if [[ ${_pragma_once_already_seen["$1"]} ]]; then
        log DEBUG "'${BASH_SOURCE[2]##*/}' line ${BASH_LINENO[1]}: source '${1##*/}' skipped"
        return ${_pragma_once_already_seen["$1"]}
    fi

    [ -e "$1" ] && builtin source "$1"
    local _exit=$?

    # save exit state
    [[ ${_pragma_once_already_seen["$1"]} ]] && _pragma_once_already_seen["$1"]=$_exit

    if [[ $_exit -ne 0 ]]; then
        log DEBUG "$1 returned non-zero code."
    fi

    return $_exit
}

function include() {
    local script="$(basename ${BASH_SOURCE[1]} | awk "{ sub(/^[^.]*/, \"$1\"); print }")"
    script="$(builtin cd "$(dirname "${BASH_SOURCE[1]}" )" && pwd)/${script}"

    source_impl $script
}

function source() {
    local script=$1
    [ "$script" = "${script#/}" ] && script="$(builtin cd "$(dirname "$1" )" && pwd)/${1##*/}"

    source_impl $script
}

alias .=source

function cleanup_pragma_once() {
    unset -f _pragma_once
    unset _pragma_once_already_seen
    unalias pragma_once

    unset -f _source_once
    unset -f include
    unset -f source
    unalias .
}

source ${_DOT_BASH_BASEDIR}/.bash/lib/log.lib.bash

# see cleanup.bash
declare -g -a CLEANUP_HANDLER

CLEANUP_HANDLER+=(cleanup_pragma_once)