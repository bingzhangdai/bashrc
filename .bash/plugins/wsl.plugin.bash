if _is_in_wsl; then
    # ignore treating *.dll files as executable under WSL
    export EXECIGNORE=*.dll

    # invoke Windows exe when there is not Linux one with the same name
    # https://github.com/microsoft/WSL/issues/2003#issuecomment-297792622
    eval "$(echo "orig_command_not_found_handle()"; declare -f command_not_found_handle | tail -n +2)"
    command_not_found_handle() {
        if cmd.exe /c "(where $1 || (help $1 |findstr /V Try)) >nul 2>nul && ($* || exit 0)"; then
            return $?
        else
            # if [ -x /usr/lib/command-not-found ]; then
            #     /usr/lib/command-not-found -- "$1"
            #     return $?
            # elif [ -x /usr/share/command-not-found/command-not-found ]; then
            #     /usr/share/command-not-found/command-not-found -- "$1"
            #     return $?
            # else
            #     printf "%s: command not found\n" "$1" >&2
            #     return 127
            # fi
            orig_command_not_found_handle $*
        fi
    }
fi