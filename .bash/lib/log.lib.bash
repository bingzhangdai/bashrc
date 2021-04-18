pragma_once

declare -g -A LogLevelEnum
LogLevelEnum["TRACE"]=0
LogLevelEnum["DEBUG"]=1
LogLevelEnum["INFO"]=2
LogLevelEnum["WARN"]=3
LogLevelEnum["ERROR"]=4

# first argument (optional, default to INFO) is log level
# exmaple: log 'hello world!'
# example: log ERROR 'no such file or directory.'

_is_loglevel_enabled() {
    [[ "${LogLevelEnum[$1]}" -ge "${LogLevelEnum[${LOGLEVEL:-ERROR}]}" ]]
}

log() {
    local level="$1"
    if [ -v "LogLevelEnum[$level]" ]; then
        shift
    else
        level=INFO
    fi

    ! _is_loglevel_enabled $level && return

    local time
    # bash version >= 4.2
    if [ "${BASH_VERSINFO[0]}" -gt 4 ] || { [ "${BASH_VERSINFO[0]}" -eq 4 ] && [ "${BASH_VERSINFO[1]}" -ge 2 ]; }; then
        local ms=0
        get_miliseconds ms
        printf -v time '%(%b %-d %T)T.%d' -1 $(( ms % 1000 ))
    else
        printf -v time '%s' "$(date +"%b %-d %T.%3N")"
    fi

    local msg="${BASH_SOURCE[1]##*/}[${BASH_LINENO[0]}]: $*"

    case "$level" in
        TRACE)
            [ -t 1 ] && level="${DARK_GRAY}${level}${NONE}" ;;&
        DEBUG)
            [ -t 1 ] && level="${GREEN}${level}${NONE}" ;;&
        INFO)
            [ -t 1 ] && level="${WHITE}${level}${NONE}" ;;&
        TRACE|DEBUG|INFO)
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
