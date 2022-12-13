# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

## source scripts in .bash folder
# require bash version 4+
case $BASH_VERSION in
    ''|[0-3].*)
        echo "ERROR: Bash 4.0+ required" > /dev/stderr
        return
    ;;
esac

# ANSI C locale
# export LC_ALL='C'
# export LC_ALL='zh_CN.UTF-8'
unset LC_ALL

if [ -f ~/.settings.bash ]; then
    source ~/.settings.bash
fi

if [ -d ~/bin ]; then
    PATH=~/bin:$PATH
fi

## default editor
export EDITOR='vi'

_DOT_BASH_BASEDIR="$(builtin cd $(dirname ${BASH_SOURCE[0]}) && builtin pwd)"

PATH=$PATH:$_DOT_BASH_BASEDIR/bin

# https://stackoverflow.com/questions/5014823/how-to-profile-a-bash-shell-script-slow-startup
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

declare -g -a CLEANUP_HANDLER

function cleanup() {
    unset -f source
    unalias .
    unset _DOT_BASH_CACHE
    unset _SOURCED_FILES

    local handle
    for handle in $CLEANUP_HANDLER; do
        if declare -F "$handle" > /dev/null; then
            $handle
            unset -f $handle
        else
            log ERROR "cannot find cleanup callback: '$handle'"
        fi
    done

    unset CLEANUP_HANDLER
    unset -f cleanup
}

# lib should be sourced first. It contais predefined vars and funcs 
# completions should be sourced before plugins, otherwise, system.completion.bash will overwrite plugin's (fzf.plugin.bash)
# plugins should be sourced before aliases

for path in ./{lib,completions,plugins,aliases}; do
    path=$(path::abs $path)
    for file in $(sort <(ls -1 $path/*.bash 2> /dev/null)); do
        [[ -e "$file" ]] && source "$file"
        [[ "$?" -ne "0" ]] && logger.log WARN "'$file' returned non-zero code."
    done
done
unset path file

# theme
source ./theme.bash

cleanup

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [[ "$OPT_ENABLE_AUTO_UPDATE" == yes ]]; then
    : ${OPT_AUTO_UPDATE_PERIOD:=30}
    function __prompt_update() (
        local _file=${_DOT_BASH_BASEDIR}/cache/update_history
        local _timestamp; printf -v _timestamp '%(%s)T' '-1'

        [[ -r "$_file" ]] && source "$_file"
        ! (( last_updated_timestamp )) && {
            __write_update_record
            return
        }

        if (( last_updated_timestamp + OPT_AUTO_UPDATE_PERIOD * 24 * 3600 < _timestamp )); then
            local _update
            read -p "Update your bashrc?[Y/N] " _update
            if [[ "$_update" == Y ]]; then
                bash -c "$(curl -fsSL https://raw.githubusercontent.com/bingzhangdai/bashrc/main/scripts/install)"
                __write_update_record
            fi
        fi
    )

    function __write_update_record() {
        local _file=${_DOT_BASH_BASEDIR}/cache/update_history
        local _timestamp; printf -v _timestamp '%(%s)T' '-1'
        [[ ! -e "$_file" ]] && touch "$_file"
        echo "last_updated_timestamp=$_timestamp;" >| "$_file"
    }

    __prompt_update
    unset -f __write_update_record __prompt_update
fi
