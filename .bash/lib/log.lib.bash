# You can specify one of the following severity levels (in increasing order of severity): INFO, WARNING, ERROR, and FATAL. Logging a FATAL message terminates the program (after the message is logged). Note that messages of a given severity are logged not only in the logfile for that severity, but also in all logfiles of lower severity. E.g., a message of severity FATAL will be logged to the logfiles of severity FATAL, ERROR, WARNING, and INFO.

pragma_once

include color
include map

# region log level

LOG_DEBUG=0
LOG_INFO=1
LOG_WARN=2
LOG_ERROR=3
LOG_FATAL=4

declare -g -A _log_loglevel_enum
_log_loglevel_enum['DEBUG']=$LOG_DEBUG
_log_loglevel_enum['INFO']=$LOG_INFO
_log_loglevel_enum['WARN']=$LOG_WARN
_log_loglevel_enum['ERROR']=$LOG_ERROR
_log_loglevel_enum['FATAL']=$LOG_FATAL

declare -g -a _log_loglevel_rev=('DEBUG' 'INFO' 'WARN' 'ERROR' 'FATAL')

# the defaul log level
if [ -z "$_log_loglevel" ]; then
    _log_lib_loglevel=$LOG_ERROR
fi

# log messages at or above this level, default is ERROR
function logger::minloglevel() {
    _log_lib_loglevel=${_log_loglevel_enum["$1"]}
}

function logger::is_enabled() {
    [ "${_log_loglevel_enum[$1]}" -ge "$_log_lib_loglevel" ]
}

# get the current loglevel
function logger::loglevel() {
    echo "${_log_loglevel_rev[$_log_lib_loglevel]}"
}

# endregion

function logger::_get_current_time() {
    local current_time
    if [ ${BASH_VERSINFO} -ge 5 ]; then
        printf -v current_time '%(%m%d %H:%M:%S)T.%06d' -1 $(( ${EPOCHREALTIME/./} / 1000 % 1000 ))
    else
        if command -v gdate > /dev/null; then
            current_time=$(gdate +%m%d_%H:%M:%S.%N)
        else
            current_time=$(date +'%m%d %H:%M:%S.%6N')
        fi
    fi

    printf -v $1 '%s' "$current_time"
}

logger::log() {
    local level="$1"
    if map::contains_key $level _log_loglevel_enum; then
        shift
    else
        level=INFO
    fi

    ! logger::is_enabled $level && return
    [ /dev/stderr -ef /dev/null ] && return

    local source_file="${BASH_SOURCE[1]##*/}":"${BASH_LINENO[0]}"
    if [ ${#BASH_SOURCE[@]} -eq 1 ]; then
        if [ "${BASH_SOURCE[0]}" = 'main' ]; then
            # e.g. call from function directly
            source_file="${BASH_SOURCE[0]}":"${BASH_LINENO[0]}"
        else
            # call from shell directly
            source_file="$0":"${BASH_LINENO[0]}"
        fi
    fi

    local time
    logger::_get_current_time time

    local format color
    case "$level" in
        DEBUG)
        color=$GREEN
            format="D$time $$ $source_file] %s\n"
            ;;
        INFO)
            color=$NONE
            format="I$time $$ $source_file] %s\n"
            ;;
        WARN)
            color=$YELLOW
            format="W$time $$ $source_file] %s\n"
            ;;
        ERROR)
            color=$RED
            format="E$time $$ $source_file] %s\n"
            ;;
        FATAL)
            color=$RED
            format="F$time $$ $source_file] %s\n"
            ;;
        *)
            color=$NONE
            format="$level$time $$ $source_file] %s\n"
            ;;
    esac

    [ -t 2 ] && format="$color$format$NONE"

    printf "$format" "$*" > /dev/stderr

    if [ "$level" = 'FATAL' ]; then
        exit 1
    fi
}
