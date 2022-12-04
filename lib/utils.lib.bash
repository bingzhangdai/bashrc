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

    : $({ time for ((_bench_it=1; _bench_it<iter; _bench_it++)); do eval "$*" &>> /dev/null; done; } 2>&1)
    : "${_/./}"
    : "${_#"${_%%[!0]*}"}"
    : $(( _ + time ))
    >&2 printf '%d iterations, average: %d.%02dms\n' "$iter" "$(( _ / iter ))" "$(( _ % iter * 100 / iter ))"
    return $_exit
)

: ${OPT_AUTO_UPDATE_PERIOD:=30}
function __prompt_update() (
    local _file=${_DOT_BASH_BASEDIR}/cache/update_history
    local _timestamp; printf -v _timestamp '%(%s)T' '-1'

    [[ -r "$_file" ]] && source "$_file"
    ! (( last_updated_timestamp )) && {
        __write_update_record
        return
    }

    if (( last_updated_timestamp + OPT_AUTO_UPDATE_PERIOD * 24 * 3600 < _timestamp )); then
        local _update
        read -p "Update your bashrc?[Y/N] " _update
        if [[ "$_update" == Y ]]; then
            bash -c "$(curl -fsSL https://raw.githubusercontent.com/bingzhangdai/bashrc/main/scripts/install)"
            __write_update_record
        fi
    fi
)

function __write_update_record() {
    local _file=${_DOT_BASH_BASEDIR}/cache/update_history
    local _timestamp; printf -v _timestamp '%(%s)T' '-1'
    [[ ! -e "$_file" ]] && touch "$_file"
    echo "last_updated_timestamp=$_timestamp;" >| "$_file"
}

__prompt_update
unset -f __write_update_record __prompt_update
