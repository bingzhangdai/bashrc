# string join function
#
# The following options are available:
#   -d, --delimiter DELI    delimiter (defaulting to ' ') to be attached with each element
#   -o, --output VAR        the variable to save the joined string to
#
# usage:
#   join delimiter string...
# example:
#   join ',' 'a' 'b' 'c' -> 'a,b,c'
function str::join() {
    local deli=' ' val='' output_var=''
    while [[ "$1" == -* ]]; do
        case "$1" in
            --)
                shift
                break
                ;;
            -d|--delimiter)
                deli="$2"
                shift 2
                ;;
            -o|--output)
                output_var="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: str::join [-d|--delimiter DELI] [-o|--output VAR] string..."
                return 0
                ;;
            -*)
                echo "Unknown option: $1" >&2
                str::join --help >&2
                return 1
                ;;
        esac
    done

    val="$1"
    shift
    for arg in "$@"; do
        val+="$deli$arg"
    done

    if [ -n "$output_var" ]; then
        printf -v "$output_var" '%s' "${val// /\ }"
    else
        echo $val
    fi
}

