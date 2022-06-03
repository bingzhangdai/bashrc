# You can specify one of the following severity levels (in increasing order of severity): INFO, WARNING, ERROR, and FATAL. Logging a FATAL message terminates the program (after the message is logged). Note that messages of a given severity are logged not only in the logfile for that severity, but also in all logfiles of lower severity. E.g., a message of severity FATAL will be logged to the logfiles of severity FATAL, ERROR, WARNING, and INFO.
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

# the defaul log level
if [ -z "$_log_loglevel" ]; then
    _log_lib_loglevel=ERROR
fi

# log messages at or above this level, default is ERROR
function logger::minloglevel() {
    if ! map::contains_key $1 _log_loglevel_enum; then
        logger::log ERROR "invalid log level '$1'"
        return 1
    fi
    _log_lib_loglevel=$1
}

function logger::is_enabled() {
    [ "${_log_loglevel_enum[$1]}" -ge "${_log_loglevel_enum[$_log_lib_loglevel]}" ]
}

# get the current loglevel
function logger::loglevel() {
    echo "${_log_loglevel_rev[$_log_lib_loglevel]}"
}

# endregion

function logger::_get_current_time() {
    local current_time
    if [ ${BASH_VERSINFO} -ge 5 ]; then
        printf -v current_time '%(%m%d %H:%M:%S)T.%06d' -1 $(( ${EPOCHREALTIME/./} % 1000000 ))
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

    local source_file="${BASH_SOURCE[1]##*/}"
    source_file="${source_file:-$0}":"${BASH_LINENO[0]}"

    local time
    logger::_get_current_time time

    local format color
    case "$level" in
        DEBUG)
        color=$GREEN
            format="D$time $BASHPID $source_file] %s"
            ;;
        INFO)
            color=$NONE
            format="I$time $BASHPID $source_file] %s"
            ;;
        WARN)
            color=$YELLOW
            format="W$time $BASHPID $source_file] %s"
            ;;
        ERROR)
            color=$RED
            format="E$time $BASHPID $source_file] %s"
            ;;
        FATAL)
            color=$RED
            format="F$time $BASHPID $source_file] %s"
            ;;
        *)
            color=$NONE
            format="$level$time $BASHPID $source_file] %s"
            ;;
    esac

    [ -t 2 ] && format="$color$format$NONE"

    >&2 printf "$format\n" "$*"

    if [ "$level" = 'FATAL' ]; then
        exit 1
    fi
}
