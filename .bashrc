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

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
color_prompt=yes
eliminate_ambiguity=no

# uncomment to add git information to the prompt
git_prompt=yes

# uncomment to enable fish-style working directory in your command prompt
fish_prompt=yes

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

# region profile
function get_miliseconds() {
    if [ ${BASH_VERSINFO} -ge 5 ]; then
        printf -v "$1" '%s' "$((${EPOCHREALTIME/./}/1000))"
    else
        printf -v "$1" '%s' "$(date +%s%3N)"
    fi
}
# start time
get_miliseconds start_time
# endregion

export _DOT_BASH_BASEDIR="$(builtin cd $(dirname ${BASH_SOURCE[0]}) && pwd)"

# https://stackoverflow.com/questions/5014823/how-to-profile-a-bash-shell-script-slow-startup
builtin source "${_DOT_BASH_BASEDIR}"/.bash/setup.bash

# lib should be sourced first. It contais predefined vars and funcs 
# completions should be sourced before plugins, otherwise, system.completion.bash will overwrite plugin's (fzf.plugin.bash)
# plugins should be sourced before aliases
timelogger_start 1 TRACE
for path in "${_DOT_BASH_BASEDIR}"/.bash/{lib,completions,plugins,aliases}; do
    for file in $(sort <(ls -1 $path/*.bash 2> /dev/null)); do
        [[ -e "$file" ]] && source "$file"
        [[ "$?" -ne "0" ]] && log WARN "'$file' returned non-zero code."
        timelogger_log_interval 1 "source ${file##*/} used %s."
    done
done
unset path file

# theme
builtin source "${_DOT_BASH_BASEDIR}"/.bash/theme.bash
timelogger_log_interval 1 "source theme.bash used %s."

# clean up
builtin source "${_DOT_BASH_BASEDIR}"/.bash/cleanup.bash
timelogger_log_interval 1 "source cleanup.bash used %s."

# region profile
# end time
get_miliseconds end_time
log  "total time spent: $(((end_time - start_time) / 1000))s $(((end_time - start_time) % 1000))ms."
# endregion
