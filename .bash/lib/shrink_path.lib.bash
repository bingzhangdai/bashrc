# Shrink paths, e.g. /foo/bar/quux -> /f/b/quux.
#
# This lib can shrink any kind of path-like argument, e.g. git branch name:
#   shrink_path.feature/user_name/branch_name -> f/u/branch_name
#
# The following options are available:
#
#   -d, --directory     The path is assumed to be a directory, and will by default eliminate
#                       the ambiguity, equivalent to -f _is_path_ambiguous
#   -f FUNC             The function to indicate if the path trunncated prefix is ambigous, names
#                       will be collapsed to their shortest unambiguous form. The function must
#                       return 0 if the path is ambiguous. Without this option, the directory name
#                       is truncated without checking if it is ambiguous.
#   -#                  Truncate each directly to at least this many characters exclusive of the
#                       period character(s) (defaulting to 1).
#   -e VAR              The variable to save the shrunken path to.

# return true if the path prefix is ambuguous
function _is_path_ambiguous() {
    local prefix="${1/#\~/$HOME}"
    local list_files=("$prefix"*)
    [ "${#list_files[@]}" -ne 1 ]
}

function _default_is_path_ambiguous() {
    false
}

function shrink_path() {
    local is_anbiguous_func=_default_is_path_ambiguous length=1
    local output_var=''

    while [[ "$1" == -* ]]; do
        case "$1" in
            --)
                shift
                break
                ;;
            -d|--directory)
                is_anbiguous_func=_is_path_ambiguous
                ;;
            -f)
                _is_path_ambiguous="$2"
                shift
                ;;
            -[0-9]|-[0-9][0-9])
                length=${1/-/}
                ;;
            -e)
                output_var="$2"
                shift
                ;;
            -h|--help)
                echo "Usage: shrink_path [-d|--directory] [-f FUNC] [-#] [-e VAR] PATH"
                return 0
                ;;
            -*)
                echo "Unknown option: $1" >&2
                shrink_path --help >&2
                return 1
                ;;
        esac
        shift
    done

    local path="$1"
    local dir='' realdir='' 
    if [[ "${path:0:1}" == '/' ]]; then
        dir='/'
        realdir='/'
    fi
    # remove tailing '/'
    local path="${path%%*(/)}"
    # basename
    local base="${path##*/}"
    local d
    local directories
    IFS='/' read -ra directories <<< ${path%"$base"}
    for d in ${directories[@]}; do
        [[ -z "$d" ]] && continue
        
        if [[ "$d" == '.' ]]; then
            continue
        fi

        if [[ "$d" == '..' ]]; then
            realdir="${realdir%/*/}/"
            dir="${dir%/*/}/"
            continue
        fi


        local prefix="$realdir" leading_period=true
        for ((i = 0; i < ${#d}; i++)); do
            local char="${d:$i:1}"

            prefix+="$char"
            dir+="$char"

            if [[ "$char" == '.' ]] && $leading_period; then
                continue
            else
                leading_period=false

                if (( i + 1 >= length )) && ! $is_anbiguous_func "$prefix"; then
                    break
                fi
            fi
        done

        realdir="$realdir$d/"
        dir="$dir/"
    done

    if [ -n "$output_var" ]; then
        printf -v "$output_var" '%s' "${dir}${base}"
    else
        printf '%s\n' "${dir}${base}"
    fi
}
