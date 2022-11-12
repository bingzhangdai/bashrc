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
    local time=$({ time for _ in {0..100}; do eval "$*" &>> /dev/null; done; } 2>&1)
    : "${time/./}"
    : "${_#"${_%%[!0]*}"}"
    printf '%d.%2dms\n' "$(( _ / 100 ))" "$(( _ % 100 ))"
)
