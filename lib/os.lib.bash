function os::wsl_version() {
    local verson='';
    # mac does not have /proc/version
    [[ -f /proc/version ]] && version="$(</proc/version)"
    if [[ "$version" = *[Mm]icrosoft* ]]; then
        [[ "${version^^}" = *WSL2* ]] && printf 2 || printf 1
        return
    fi
    false
}

function os::is_wsl() {
    # $WSL_DISTRO_NAME is available since WSL builds 18362, also for WSL2
    [[ -n "$WSL_DISTRO_NAME" ]] && return
    [[ -n "$(uname -r | sed -E 's/^[0-9.]+-([0-9]+)-Microsoft.*|.*/\1/')" ]] && return
    os::wsl_version > /dev/null
}

# try: uname -s
function os::is_mac() {
    [[ "$OSTYPE" == 'darwin'* ]]
}

# store the homebrew prefix, avoid unncessary calls of brew command
if command -v brew > /dev/null; then
    _brew_prefxi="$(brew --prefix)"
    if os::is_mac && command -v gls > /dev/null; then
        PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
    fi
    PATH="$(brew --prefix grep)/libexec/gnubin:$PATH"
fi

# https://www.freedesktop.org/software/systemd/man/os-release.html
if [ -f /etc/os-release ]; then
    . /etc/os-release
elif [ -f /usr/lib/os-release ]; then
    . /usr/lib/os-release
elif [ -f /etc/initrd-release ]; then
    . /etc/initrd-release
elif [ -f /usr/lib/extension-release.d/extension-release.IMAGE ]; then
    . /usr/lib/extension-release.d/extension-release.IMAGE
fi

function os::os_family() {
    if os::is_mac; then
        echo 'darwin'
        return
    fi
    # linux
    case "$ID $ID_LIKE" in
        *debian*)
            echo 'debian' ;;
        *lede*)
            echo 'lede' ;;
        *rhel*)
            echo 'redhat' ;;
        *)
            # suse, archlinux, gentoo, mandrake, solaris, alpine, freebsd, etc.
            echo "${ID:-linux}" ;;
    esac
}

