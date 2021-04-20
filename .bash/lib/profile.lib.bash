pragma_once

function get_miliseconds() {
    if [ ${BASH_VERSINFO} -ge 5 ]; then
        printf -v "$1" '%s' "$((${EPOCHREALTIME/./}/1000))"
    else
        printf -v "$1" '%s' "$(date +%s%3N)"
    fi
}

declare -g -a _timelogger_last_log_time

# timelogger_start(id)
function timelogger_start() {
    local loglevel=TRACE
    ! _is_loglevel_enabled "$loglevel" && return
    local start_time
    get_miliseconds start_time
    _timelogger_last_log_time["$1"]=start_time
}

# timelogger_log_interval(id, format)
function timelogger_log_interval() {
    local loglevel=TRACE
    ! _is_loglevel_enabled "$loglevel" && return

    local end_time
    get_miliseconds end_time

    local msg
    printf -v msg "$2" $(( "${end_time}" - "${_timelogger_last_log_time["$1"]}" ))
    log "$loglevel" "$msg"

    _timelogger_last_log_time["$1"]="$end_time"
}
