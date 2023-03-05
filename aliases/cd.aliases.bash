# https://github.com/rse/bash-fzf
declare -a -g CDSTACK=()
declare -a -g CDREVSTACK=()

# enhance change directory command
cd() {
    local result=0

    # change current working directory
    if [[ "$1" == "-" ]]; then
        # go to previous working directory on forward directory stack
        # and move this directory onto the reverse directory stack
        if ! arr.is_empty CDSTACK; then
            local _i=$((${#CDSTACK[*]} - 1))
            local _dest="${CDSTACK[$_i]}"
            builtin cd "$_dest"
            result="$?"
            arr.push_back CDREVSTACK "$OLDPWD"
            arr.pop_back CDSTACK
        else
            echo "-bash: cd: ERROR: no more previous working directories on forward directory stack" 1>&2
            result=1
        fi
    elif [[ "$1" == "+" ]]; then
        # go to previous working directory on reverse directory stack
        # and move this directory onto the forward directory stack
        if ! arr.is_empty CDREVSTACK; then
            local _i=$((${#CDREVSTACK[*]} - 1))
            local _dest="${CDREVSTACK[$_i]/#~/$HOME}"
            builtin cd "$_dest"
            result="$?"
            arr.push_back CDSTACK "$OLDPWD"
            arr.pop_back CDREVSTACK
        else
            echo "-bash: cd: ERROR: no more previous working directories on reverse directory stack" 1>&2
            result=1
        fi
    else
        # go to next working directory
        # "$*" is not correct: `cd -- .bash`
        builtin cd "$@"
        result="$?"
        if [[ "$result" -eq 0 ]]; then
            # go back and use pushd to change dir
            arr.push_back CDSTACK "$OLDPWD"
            # erase reverse directory stack
            CDREVSTACK=()
            # avoid duplicates on forward directory stack
            if [[ "${#CDSTACK[*]}" -ge 2 && "${CDSTACK[0]/#~/$HOME}" == "${CDSTACK[1]/#~/$HOME}" ]]; then
                arr.pop_back CDSTACK
            fi

        fi
    fi

    return $result
}
