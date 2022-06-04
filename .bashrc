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

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

## less
export LESS='-R -S -M -i -# .2'

## default editor
export EDITOR='vi'

if [ -f ~/.theme.bash ]; then
    source ~/.theme.bash
fi

# region setup

_DOT_BASH_BASEDIR="$(builtin cd $(dirname ${BASH_SOURCE[0]}) && builtin pwd)"

# endregion


# https://stackoverflow.com/questions/5014823/how-to-profile-a-bash-shell-script-slow-startup
source "${_DOT_BASH_BASEDIR}"/.bash/setup.bash

logger.minloglevel DEBUG

# lib should be sourced first. It contais predefined vars and funcs 
# completions should be sourced before plugins, otherwise, system.completion.bash will overwrite plugin's (fzf.plugin.bash)
# plugins should be sourced before aliases

for path in ./.bash/{lib,completions,plugins,aliases}; do
    path=$(path.abs $path)
    for file in $(sort <(ls -1 $path/*.bash 2> /dev/null)); do
        [[ -e "$file" ]] && source "$file"
        [[ "$?" -ne "0" ]] && logger.log WARN "'$file' returned non-zero code."
    done
done
unset path file

# theme
source ./.bash/theme.bash

# clean up
builtin source "${_DOT_BASH_BASEDIR}"/.bash/cleanup.bash

