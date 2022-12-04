function error::explain() {
    case "$1" in
        0): 'Successful' ;;
        1) : 'Catchall for general errors' ;;
        2) : 'Misuse of shell builtins (according to Bash documentation)' ;;
        126) : 'Command invoked cannot execute' ;;
        127) : 'Command not found' ;;
        128) : 'Invalid argument to exit' ;;
        130) : 'Script terminated by Control-C' ;;
        255) : 'Exit status out of range' ;;
        *)
            if (( $1 > 128 )); then
                # the actual meaning of signal varies among platforms
                : $(kill -l | grep -Po "[^0-9]$(($1 - 128))\) \K[[:alnum:]]+")
                : "Fatal error signal \"${_:-$(($1 - 128))}\""
            else
                : 'Undefined exit code'
            fi
        ;;
    esac
    printf "exit %d: %s\n" "$1" "$_"
}
