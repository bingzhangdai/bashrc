# source lib/os.lib.bash

if ! os::is_wsl; then
    logger.log INFO "not in wsl, skipped"
    return
fi

# ignore treating *.dll files as executable under WSL
export EXECIGNORE=*.dll:*.pdb:*.mof:*.ini

# invoke Windows exe when there is not Linux one with the same name
# https://github.com/microsoft/WSL/issues/2003#issuecomment-297792622
if declare -F command_not_found_handle > /dev/null; then
    fun::rename command_not_found_handle wsl_orig_command_not_found_handle
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
    # powershell is too slow
    # if powershell.exe Get-Command "$1" -errorAction SilentlyContinue > /dev/null; then
    if [[ -x $WSL_AUTOMOUNT_ROOT/c/WINDOWS/system32/cmd.exe ]] && $WSL_AUTOMOUNT_ROOT/c/WINDOWS/system32/cmd.exe /c "(help $1 > nul || exit 0) && where $1 > nul 2> nul"; then
        printf "Fallback: execute Windows command '$1' in cmd.exe\n"

        if [[ "$EUID" == 0 ]] && [[ -x $WSL_AUTOMOUNT_ROOT/c/WINDOWS/system32/where.exe ]] &&  $WSL_AUTOMOUNT_ROOT/c/WINDOWS/system32/where.exe gsudo > /dev/null 2>&1; then
            $WSL_AUTOMOUNT_ROOT/c/WINDOWS/system32/cmd.exe /c "gsudo -d $*"
        else
            $WSL_AUTOMOUNT_ROOT/c/WINDOWS/system32/cmd.exe /c "$*"
        fi
    else
        wsl_orig_command_not_found_handle "$*"
    fi
    # if cmd.exe /c "(where $1 || (help $1 |findstr /V Try)) >nul 2>nul && ($* || exit 0)"; then
    #     return $?
    # else
    #     wsl_orig_command_not_found_handle $*
    # fi
}
expose -f wsl_orig_command_not_found_handle
expose -f command_not_found_handle
expose WSL_AUTOMOUNT_ROOT

# install dependencies
# install gsudo (https://github.com/gerardog/gsudo)
gsudo="${_DOT_BASH_CACHE}/gsudo.plugin.bash"
if ! command -v gsudo > /dev/null && command -v winget.exe; then
    winget.exe install --accept-source-agreements --accept-package-agreements gerardog.gsudo
fi
unset gsudo
