# This defines where cd looks for targets
# Add the directories you want to have fast access to, separated by colon
# Ex: CDPATH=".:~:~/projects" will look for targets in the current working directory, in home and in the ~/projec
CDPATH=".:~"

# `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
shopt -s autocd

# correct spelling errors during tab-completion
shopt -s dirspell

# autocorrect typos in path names when using `cd`
shopt -s cdspell;

# do not replace directory names with the results of word expansion when performing filename completion
# shopt -u direxpand

# This allows you to bookmark your favorite places across the file system
# Define a variable containing a path and you will be able to cd into it regardless of the directory you're in
# shopt -s cdable_vars

# https://github.com/rse/bash-fzf
# declare reverse DIRSTACK array
declare -a DIRSTACKREV=()

# enhance change directory command
cd () {
    local result=0

    # change current working directory
    if [[ "$1" == "-" ]]; then
        # go to previous working directory on forward directory stack
        # and move this directory onto the reverse directory stack
        if [[ ${#DIRSTACK[*]} -gt 1 ]]; then
            DIRSTACKREV[${#DIRSTACKREV[*]}]="${DIRSTACK[0]}"
            builtin popd > /dev/null
            result="$?"
        else
            echo "-bash: cd: ERROR: no more previous working directories on forward directory stack" 1>&2
            result=1
        fi
    elif [[ "$1" == "+" ]]; then
        # go to previous working directory on reverse directory stack
        # and move this directory onto the forward directory stack
        if [[ ${#DIRSTACKREV[*]} -gt 0 ]]; then
            local i=$((${#DIRSTACKREV[*]} - 1))
            builtin pushd "${DIRSTACKREV[$i]/#~/$HOME}" > /dev/null
            result="$?"
            unset DIRSTACKREV["$i"]
        else
            echo "-bash: cd: ERROR: no more previous working directories on reverse directory stack" 1>&2
            result=1
        fi
    else
        # go to next working directory
        if [ $# -ge 1 ]; then
            builtin cd "$*"
        else
            # `cd` and `cd ''` is different
            builtin cd
        fi
        result="$?"
        if [[ "$result" -eq 0 ]]; then
            # go back and use pushd to change dir
            builtin cd - > /dev/null
            builtin pushd "$OLDPWD" > /dev/null
            # avoid duplicates on forward directory stack
            if [[ "${#DIRSTACK[*]}" -ge 2 && "${DIRSTACK[0]/#~/$HOME}" == "${DIRSTACK[1]/#~/$HOME}" ]]; then
                builtin popd -n > /dev/null
            fi
            # erase reverse directory stack
            DIRSTACKREV=()
        fi
    fi

    return $result
}
