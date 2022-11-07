# execute the command without changing the exit code
clean_call() {
    # preserve exit status
    local exit=$?
    if command -v "$1" >> /dev/null; then
        $@
    else
        eval "$@"
    fi
    return "$exit"
}
