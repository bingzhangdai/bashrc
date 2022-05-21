function _get_wsl_version() {
    local verson='';
    # mac does not have /proc/version
    [ -f /proc/version ] && version="$(cat /proc/version)";
    if echo "$version" | grep -iqF microsoft; then
        echo "$version" | grep -iqF wsl2 && printf 2 || printf 1
    fi
}

function _is_in_wsl() {
    # $WSL_DISTRO_NAME is available since WSL builds 18362, also for WSL2
    [[ -n "$WSL_DISTRO_NAME" ]] && return
    [[ -n "$(uname -r | sed -E 's/^[0-9.]+-([0-9]+)-Microsoft.*|.*/\1/')" ]] && return
    [[ -n "$(_get_wsl_version)" ]]
}

if [ -f /etc/os-release ]; then
    . /etc/os-release
fi