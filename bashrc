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

source "$(builtin cd $(dirname ${BASH_SOURCE[0]}) && builtin pwd)/scripts/bootstrap.bash"

_DOT_BASH_CACHE="$_DOT_BASH_BASEDIR/cache"

# load logging library
. lib/log.lib.bash

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

unset _DOT_BASH_CACHE
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

# dedup PATH
