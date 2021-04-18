pragma_once

declare -g -A LogLevelEnum
LogLevelEnum["DEBUG"]=1
LogLevelEnum["INFO"]=2
LogLevelEnum["WARN"]=3
LogLevelEnum["ERROR"]=4

# first argument (optional, default to INFO) is log level
# exmaple: log 'hello world!'
# example: log ERROR 'no such file or directory.'
log() {
    local level="$1"
    if [ -v "LogLevelEnum[$level]" ]; then
        shift
    else
        level=INFO
    fi

    [[ "${LogLevelEnum[$level]}" -lt "${LogLevelEnum[${LOGLEVEL:-ERROR}]}" ]] && return

    local time=$(date +"%b %-d %T.%3N")
    local msg="${BASH_SOURCE[1]##*/}[${BASH_LINENO[0]}]: $*"

    case "$level" in
        DEBUG)
            [ -t 1 ] && level="${GREEN}${level}${NONE}" ;;&
        INFO)
            [ -t 1 ] && level="${WHITE}${level}${NONE}" ;;&
        DEBUG|INFO)
            [ -t 1 ] && time="${DARK_GRAY}${time}${NONE}"
            echo "${time} ${level} ${msg}" ;;
        WARN)
            [ -t 2 ] && level="${YELLOW}${level}${NONE}" ;;&
        ERROR)
            [ -t 2 ] && level="${RED}${level}${NONE}" ;;&
        WARN|ERROR)
            [ -t 2 ] && time="${DARK_GRAY}${time}${NONE}"
            echo "${time} ${level} ${msg}" ;;
        *)
            false ;;
    esac
}
