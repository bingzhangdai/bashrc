# execute the command without changing the exit code
# split into two functions, because command -v is too slow in WSL2
#   see: https://github.com/warrensbox/terraform-switcher/issues/158
# clean_call() {
#     # preserve exit status
#     local exit=$?
#     if command -v "$1" >> /dev/null; then
#         $@
#     else
#         eval "$@"
#     fi
#     return "$exit"
# }

function clean_call() {
    # preserve exit status
    local exit=$?
    $@
    return "$exit"
}

function clean_eval() {
    local exit=$?
    eval "$*"
    return "$exit"
}


_BENCHMARK_MIN_ITER=3
function benchmark() (
    export TIMEFORMAT='%3R'
    # print the sample output
    printf "${YELLOW_B}------ begin command output ------$NONE\n"
    { time=$({ time eval "$*" 2>&1; } 2>&1 1>&3) _exit=$?; } 3>&1
    printf "${YELLOW_B}------- end command output -------$NONE\n"
    # calculate the number of iterations
    : "${time/./}"
    : "${_#"${_%%[!0]*}"}"
    time=$(( _ ? _ : 1 ))
    # (10 * 1000 - time + time/2) / time
    : $(( (10000 - time / 2) / time))
    : $(( _ + 1 ))
    : $(( _ < _BENCHMARK_MIN_ITER ? _BENCHMARK_MIN_ITER : _ ))
    : $(( _ > 100 ? 100 : _ ))
    local iter=$_

    : $({ time for ((i=1;i<iter;i++)); do eval "$*" &>> /dev/null; done; } 2>&1)
    : "${_/./}"
    : "${_#"${_%%[!0]*}"}"
    : $(( _ + time ))
    >&2 printf '%d iterations, average: %d.%02dms\n' "$iter" "$(( _ / iter ))" "$(( _ % iter * 100 / iter ))"
    return $_exit
)
