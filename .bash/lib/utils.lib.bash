# execute the command without changing the previous return status
no_return_call() {
    # preserve exit status
    local exit=$?
    local cmd="$1"
    shift
    $cmd $@
    return "$exit"
}

# eval is generally more dengerous, use it only when no_return_call fails
no_return_eval() {
    # preserve exit status
    local exit=$?
    eval "$@"
    return "$exit"
}
