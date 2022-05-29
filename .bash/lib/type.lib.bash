# get the type of variable, function, shell builtin, etc.
typeof () {
    # check function first
    # because if we have both a function and an alias, `type -t` will return alias
    # but in reality, we usually want to check function for the programming perspective
    if declare -F "$1" > /dev/null; then
        echo 'function'
        return
    fi

    # variable
    local signature=$(declare -p "$1" 2>/dev/null)
    if [ -n "$signature" ]; then
        case "$signature" in
            *'declare -a'*) echo 'array' ;;
            *'declare -A'*) echo 'map' ;;
            *'declare -i'*) echo 'integer' ;;
            *'declare -n'*) echo 'reference' ;;
            *'declare -r'*) echo 'readonly' ;;
            *'declare -t'*) echo 'trace' ;;
            *'declare -x'*) echo 'export' ;;
            *'declare --'*) echo 'any' ;;
            *) echo "unknown: $signature"; false ;;
        esac
        return
    fi

    # other types
    signature=$(type -t "$1")
    if [ -n "$signature" ]; then
        echo "$signature"
        return
    fi

    echo 'unknown'
    false
}
