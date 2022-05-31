# get the type of variable, function, shell builtin, etc.
# usage:
#   typeof variable_name
# exmaple:
#   typeof PATH -> environment variable
#   typeof typeof -> function
typeof () {
    declare -a values=()
    # variable
    local signature=$(declare -p "$1" 2>/dev/null)
    if [ -n "$signature" ]; then
        signature="${signature#*'declare -'}"
        signature="${signature%%' '*}"

        declare -a attributes=()

        case "$signature" in
            *'r'*) attributes+=('readonly') ;;
        esac

        case "$signature" in
            *'l'*) attributes+=('lower case') ;;
            *'u'*) attributes+=('upper case') ;;
        esac

        case "$signature" in
            *'a'*) attributes+=('array') ;;
            *'A'*) attributes+=('map') ;;
            *'i'*) attributes+=('integer') ;;
            *'-'*) attributes+=('string') ;;
            *'n'*) attributes+=('reference') ;;
            *'x'*) attributes+=('environment variable') ;;
            *) attributes+=('variable') ;;
        esac

        local variable_attributes;
        str::join -o variable_attributes "${attributes[@]}"
        values+=("$variable_attributes")
    fi

    # other types
    signature=$(type -t "$1")
    if [ -n "$signature" ]; then
        case "$signature" in
            'keyword') signature='shell keyword' ;;
            'builtin') signature='shell builtin' ;;
            'file') signature='executable file' ;;
        esac

        values+=("$signature")

        if [ "${values[-1]}" != 'function' ] && declare -F "$1" > /dev/null; then
            values+=('function')
        fi

        if ! [[ "${values[-1]}" = *'file' ]] && type -P "$1" > /dev/null; then
            values+=('executable file')
        fi
    fi

    if [ "${#values[@]}" != 0 ]; then
        str::join -d ', ' "${values[@]}"
    else
        echo 'unknown'
        false
    fi
}
