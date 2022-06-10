if _is_in_wsl; then
    # ignore treating *.dll files as executable under WSL
    export EXECIGNORE=*.dll

    # invoke Windows exe when there is not Linux one with the same name
    # https://github.com/microsoft/WSL/issues/2003#issuecomment-297792622
    if declare -F command_not_found_handle > /dev/null; then
        eval "$(echo "wsl_orig_command_not_found_handle()"; declare -f command_not_found_handle | tail -n +2)"
    else
        function wsl_orig_command_not_found_handle() {
            if [ -x /usr/lib/command-not-found ]; then
                /usr/lib/command-not-found -- "$1";
                return $?;
            else
                if [ -x /usr/share/command-not-found/command-not-found ]; then
                    /usr/share/command-not-found/command-not-found -- "$1";
                    return $?;
                else
                    printf "%s: command not found\n" "$1" 1>&2;
                    return 127;
                fi;
            fi
        }
    fi
    command_not_found_handle() {
        if powershell.exe Get-Command "$1" -errorAction SilentlyContinue > /dev/null; then
            powershell.exe "$@"
        else
            wsl_orig_command_not_found_handle "$*"
        fi
        # if cmd.exe /c "(where $1 || (help $1 |findstr /V Try)) >nul 2>nul && ($* || exit 0)"; then
        #     return $?
        # else
        #     wsl_orig_command_not_found_handle $*
        # fi
    }
else
    logger.log INFO "not in wsl, skipped"
fi
