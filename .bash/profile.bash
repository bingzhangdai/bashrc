function get_miliseconds() {
    if [ ${BASH_VERSINFO} -ge 5 ]; then
        printf -v "$1" '%s' "$((${EPOCHREALTIME/./}/1000))"
    else
        printf -v "$1" '%s' "$(date +%s%3N)"
    fi
}

# stopwatch_start(id, loglevel)
function stopwatch_start() {
    declare -i _watch_start=0 _watch_end=0
}

# stopwatch_log_interval(format)
function stopwatch_log_interval() {
    log TRACE "source ${file##*/} used $(( "${_trace_end}" - "${_trace_start}" )) miliseconds"
}
