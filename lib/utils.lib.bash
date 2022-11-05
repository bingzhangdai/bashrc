# execute the command without changing the previous return status
clean_call() {
    # preserve exit status
    local exit=$?
    local cmd="$1"
    shift
    $cmd $@
    return "$exit"
}

# eval is generally more dengerous, use it only when clean_call fails
clean_eval() {
    # preserve exit status
    local exit=$?
    eval "$@"
    return "$exit"
}
