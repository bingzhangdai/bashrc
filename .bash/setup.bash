export _DOT_BASH_CACHE="${_DOT_BASH_BASEDIR}/.bash/cache"


function include() {
    local script=$(basename ${BASH_SOURCE[1]} | awk "{ sub(/^[^.]*/, \"$1\"); print }")
    [ "$script" = "${script#/}" ] && script="$(builtin cd "$(dirname "${BASH_SOURCE[1]}" )" && pwd)/${script}"

    builtin source $script
}

function source() {
    local script=$1
    [ "$script" = "${script#/}" ] && script="$(builtin cd "$(dirname "$1" )" && pwd)/${1##*/}"

    builtin source "$1"
}

alias .=source

function cleanup_pragma_once() {
    unset -f _source_once
    unset -f include
    unset -f source
    unalias .
}

source ${_DOT_BASH_BASEDIR}/.bash/lib/log.lib.bash

# see cleanup.bash
declare -g -a CLEANUP_HANDLER

CLEANUP_HANDLER+=(cleanup_pragma_once)
