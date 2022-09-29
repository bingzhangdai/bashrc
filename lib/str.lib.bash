# string join function
#
# The following options are available:
#   -d, --delimiter DELI    delimiter (defaulting to ' ') to be attached with each element
#   -o, --output VAR        the variable to save the joined string to
#
# usage:
#   str::join [-d DELI] [-o VAR] [STRING...]
#
# example:
#   join 'a' 'b' 'c' -> 'a b c'
#   join -d ':' 'a' 'b' 'c' -> 'a:b:c'
#   join -o output_var 'a' 'b' 'c' -> output_var='a b c'
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

function str.to_string() {
    local -n str=$1
    printf "str %s = '%s'\n" "$1" "$str"
}

function str.to_upper() {
    echo ${1^^}
}
