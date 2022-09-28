# get the current time in miliseconds
function time::get_timestamp() {
    local ms=0
    if [ ${BASH_VERSINFO} -ge 5 ]; then
        ms="$((${EPOCHREALTIME/./}/1000))"
    else
        ms="$(date +%s%3N)"
    fi

    printf -v "$1" '%s' "$ms"
}

# formats and prints the current time under control of the format string
#
# options:
#   -v VAR      assign the output to shell variable VAR rather than display
#               it on the standard output
#
# usage:
#   time::format [-v VAR] format
#
# examples:
#   # print current date as yyyy-mm-dd HH:MM:SS in $date
#   time::format -v date '%Y-%m-%d %H:%M:%S'
function time::format() {
    local var=''
    if [ "$1" = '-v' ]; then
        var="$2"
        shift 2
    fi
    # in bash (>= 4.2), use printf builtin
    local format_time
    if [ $BASH_VERSINFO -ge 5 ] || [ $BASH_VERSINFO = 4 -a ${BASH_VERSINFO[1]} -ge 2 ]; then
        printf -v format_time "%($1)T"
    else
        format_time=$(date "+$1")
    fi

    if [ -n "$var" ]; then
        printf -v "$var" '%s' "$format_time"
    else
        echo "$format_time"
    fi
}
