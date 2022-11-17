function error::explain() {
    case "$1" in
        1) : 'Catchall for general errors' ;;
        2) : 'Misuse of shell builtins' ;;
        126) : 'Command invoked cannot execute' ;;
        127) : 'command not found' ;;
        128) : 'Invalid argument to exit' ;;
        130) : 'Script terminated by Control-C' ;;
        255) : 'Exit status out of range' ;;
        *)
            if (( $1 > 128 )); then
                : "Fatal error signal \"$(( $1 - 128 ))\""
            else
                : 'Undefined exit code'
            fi
        ;;
    esac
    printf "exit %d: %s\n" "$1" "$_"
}
