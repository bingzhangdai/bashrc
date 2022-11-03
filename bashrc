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

if [ -f ~/.settings.bash ]; then
    source ~/.settings.bash
fi

if [ -d ~/bin ]; then
    PATH=~/bin:$PATH
fi

## default editor
export EDITOR='vi'

_DOT_BASH_BASEDIR="$(builtin cd $(dirname ${BASH_SOURCE[0]}) && builtin pwd)"


# https://stackoverflow.com/questions/5014823/how-to-profile-a-bash-shell-script-slow-startup
source "${_DOT_BASH_BASEDIR}"/setup.bash

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
