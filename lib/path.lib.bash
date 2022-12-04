

function path::join() {
    local var=''
    if [ "$1" = '-v' ]; then
        var="$2"
        shift 2
    fi

    local path="$1" p
    shift
    for p in "$@"; do
        path+="/$p"
    done

    if [ -n "$var" ]; then
        printf -v "$var" '%s' "${path// /\ }"
    else
        echo $path
    fi
}

path::filename() {
    local path="$1"
    echo "${path##*/}"
}

path::_dirname() {
    local tmp=${1:-.}

    [[ $tmp != *[!/]* ]] && {
        printf '/\n'
        return
    }

    tmp=${tmp%%"${tmp##*[!/]}"}

    [[ $tmp != */* ]] && {
        printf '.\n'
        return
    }

    tmp=${tmp%/*}
    tmp=${tmp%%"${tmp##*[!/]}"}

    printf -v "$1" "${tmp:-/}"
}

path::_basename() {
    local tmp=${1%"${1##*[!/]}"}
    tmp=${tmp##*/}
    tmp=${tmp%"${2/"$tmp"}"}

    printf -v "$1" "${tmp:-/}"
}

# get the absolute path of the caller
path::caller_path() {
    if [ "${#BASH_SOURCE[@]}" -le 2 ]; then
        builtin pwd
    else
        echo "$(builtin cd $(dirname ${BASH_SOURCE[2]}) && builtin pwd)"
    fi
}

# get the absolute path of current script
function path::current_path() {
    path::caller_path
}

# get the absolute path of the file
function path::abs() {
    local file="$1"
    if ! [[ "$file" == "/"* ]]; then
        local file=$(path::caller_path)/$file
        file="$(builtin cd "$(dirname "$file")" && builtin pwd)/${file##*/}"
    fi

    echo "$file"
}

function path::is_abs() {
    local file="$1"
    [[ "$file" == "/"* ]]
}

# return true if the path prefix is ambuguous
function path::_is_dir_prefix_ambiguous() {
    local prefix="${1/#\~/$HOME}"

    # return true if it is already a full directory/file path
    if [ -d "$prefix" ] || [ -f "$prefix" ]; then
        return 0
    fi

    local noglob=false
    if [ -o noglob ]; then
        noglob=true
        set +o noglob
    fi
    local list_files=("$prefix"*)
    if [ "$noglob" = true ]; then
        set -o noglob
    fi

    [ "${#list_files[@]}" -ne 1 ]
}

function path::_default_is_dir_prefix_ambiguous() {
    false
}

# Shrink paths, e.g. /foo/bar/quux -> /f/b/quux.
#
# This lib can shrink any kind of path-like argument, e.g. git branch name:
#   path::shrink feature/user_name/branch_name -> f/u/branch_name
#
# The following options are available:
#
#   -d, --directory     The path is assumed to be a directory, and will by default eliminate
#                       the ambiguity, equivalent to -f path::is_dir_prefix_ambiguous
#   -f FUNC             The function to indicate if the path trunncated prefix is ambigous, names
#                       will be collapsed to their shortest unambiguous form. The function must
#                       return 0 if the path is ambiguous. Without this option, the directory name
#                       is truncated without checking if it is ambiguous.
#   -#                  Truncate each directly to at least this many characters exclusive of the
#                       period character(s) (defaulting to 1).
#   -o, --output VAR    The variable to save the shrunken path to.
function path::shrink() {
    local is_anbiguous_func=path::_default_is_dir_prefix_ambiguous length=1
    local output_var=''

    while [[ "$1" == -* ]]; do
        case "$1" in
            --)
                shift
                break
                ;;
            -d|--directory)
                is_anbiguous_func='path::_is_dir_prefix_ambiguous'
                ;;
            -f)
                is_dir_prefix_ambiguous="$2"
                shift
                ;;
            -[0-9]|-[0-9][0-9])
                length=${1/-/}
                ;;
            -o|--output)
                output_var="$2"
                shift
                ;;
            -h|--help)
                echo "Usage: path::shrink [-d|--directory] [-f FUNC] [-#] [-e VAR] PATH"
                return 0
                ;;
            -*)
                echo "Unknown option: $1" >&2
                path::shrink --help >&2
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
