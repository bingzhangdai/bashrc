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

function benchmark() (
    export TIMEFORMAT='%3R'
    time=$({ time for _ in {0..100}; do eval "$*" &>> /dev/null; done; } 2>&1)
    : ${time/./}
    : ${_##0}
    printf '%dms\n' "$(( (_ + 50) / 100 ))"
)
