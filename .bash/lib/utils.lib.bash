export _DOT_BASH_CACHE="$(builtin cd $(dirname ${BASH_SOURCE[0]})/../ && pwd)/cache"

# info
iecho() {
    echo ${GREEN}$*${NONE}
}

# warning
wecho() {
    echo "${YELLOW}$*${NONE}" > /dev/stderr
}

# error
eecho() {
    echo "${RED}$*${NONE}" > /dev/stderr
}

declare -A LogLevelEnum
LogLevelEnum["DEBUG"]=1
LogLevelEnum["INFO"]=2
LogLevelEnum["WARN"]=3
LogLevelEnum["ERROR"]=4

# first argument is loglevel
log() {
    local level="$1"
    shift

    if [[ ${LogLevelEnum[$level]} -lt ${LogLevelEnum[${LOGLEVEL:-ERROR}]} ]]
    case "$level" in
        DEBUG|INFO )
            commands ;;
        WARN )
            commands ;;
        ERROR)
        esac

}

util_download() {
    local URL="$1"
    local DEST="${2}"
    if [[ -z "$2" ]]; then
        # $2 empty
        DEST="${URL##*/}"
    elif [[ -d "$2" ]] || [[ -z "${2##*/}" ]]; then
        # $2 is dir
        DEST="${2}/${URL##*/}"
    fi

    local DIR="${DEST%${DEST##*/}}"
    # local DIR="$(dirname -- ${DEST})"
    if [[ -n "$DIR" ]] && [[ ! -d "$DIR" ]]; then
        mkdir "$DIR"
    fi

    if command -v curl > /dev/null; then
        curl -L "$URL" -o "$DEST"
    elif command -v wget > /dev/null; then
        wget "$URL" -O "$DEST"
    else
        eecho "ERROR: Please install curl or wget before downloading!"
        return 127
    fi
    local ex=$?
    if [[ $ex -ne 0 ]]; then
        eecho "ERROR: downloading ${URL##*/} failed!"
        return $ex
    fi
}
