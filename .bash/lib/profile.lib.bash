pragma_once

function get_miliseconds() {
    if [ ${BASH_VERSINFO} -ge 5 ]; then
        printf -v "$1" '%s' "$((${EPOCHREALTIME/./}/1000))"
    else
        printf -v "$1" '%s' "$(date +%s%3N)"
    fi
}

declare -g -a _timelogger_last_log_time
declare -g -a _timelogger_loglevel

# timelogger_start(id, loglevel(optional))
function timelogger_start() {
    local loglevel=TRACE
    [ $# -eq 2 ] && loglevel="$2"
    _timelogger_loglevel["$1"]="$loglevel"
    ! _is_loglevel_enabled "$loglevel" && return
    local start_time
    get_miliseconds start_time
    _timelogger_last_log_time["$1"]="$start_time"
}

# timelogger_log_interval(id, format)
function timelogger_log_interval() {
    local id="$1" fmt="$2" loglevel="${_timelogger_loglevel["$1"]}"
    ! _is_loglevel_enabled "$loglevel" && return

    local start_time=${_timelogger_last_log_time["$id"]} end_time
    get_miliseconds end_time
    local time_str
    printf -v time_str '%ds %dms' $(((end_time - start_time) / 1000)) $(((end_time - start_time) % 1000))

    local msg
    printf -v msg "$fmt" "$time_str"
    local _source="${BASH_SOURCE[1]##*/}" _line="${BASH_LINENO[0]}"
    log "$loglevel" "$msg"
    _timelogger_last_log_time["$id"]="$end_time"
}
