# This defines where cd looks for targets
# Add the directories you want to have fast access to, separated by colon
# Ex: CDPATH=".:~:~/projects" will look for targets in the current working directory, in home and in the ~/projec
CDPATH=".:~"

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
            builtin pushd "${DIRSTACKREV[$i]}" > /dev/null
            result="$?"
            unset DIRSTACKREV["$i"]
        else
            echo "-bash: cd: ERROR: no more previous working directories on reverse directory stack" 1>&2
            result=1
        fi
    else
        # go to next working directory
        builtin cd $*
        result="$?"
        if [[ "$result" -eq 0 ]]; then
            if [[ "$OLDPWD" != "$PWD" ]]; then
                builtin pushd -n "$PWD" > /dev/null
            fi

            # avoid duplicates on forward directory stack
            if [[ "${#DIRSTACK[*]}" -ge 2 && "${DIRSTACK[0]}" == "${DIRSTACK[1]}" ]]; then
                builtin popd -n > /dev/null
            fi

            # erase reverse directory stack
            DIRSTACKREV=()
        fi
    fi

    return $result
}
