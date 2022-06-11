# install or remove a package through package manager
# Usage:
#     package { install | remove } pkg...
function package() {
    local action="$1"
    shift
    if [ "$#" -eq 0 ] || [  "$action" != 'install' -a  "$action" != 'remove' ]; then
        echo "Usage: package { install | remove } pkg"
        return 1
    fi

    local os_family="$(os::os_family)" pkgmgr
    case  "$os_family" in
        alpine)
            pkgmgr="apk" ;;
        archlinux)
            pkgmgr="pacman" ;;
        darwin)
            pkgmgr="brew" ;;
        debian)
            pkgmgr="apt-get" ;;
        freebsd)
            pkgmgr="pkg" ;;
        lede)
            pkgmgr="opkg" ;;
        redhat)
            pkgmgr="yum" ;;
        *)
            echo "Unsupported OS: $os_family"
            return 1
            ;;
    esac

    if [ "$action" == 'install' ]; then
        case "$os_family" in
            alpine)
                action='add' ;;
            archlinux)
                action='-S' ;;
            debian)
                action='install -y' ;;
            redhat)
                action='install -y' ;;
        esac
    elif [ "$action" == 'remove' ]; then
        case "$os_family" in
            archlinux)
                action='-R' ;;
            darwin)
                action='uninstall' ;;  
            debian)
                action='remove -y' ;;
            redhat)
                action='remove -y' ;;
        esac
    fi

    $pkgmgr $action "$@"
}
