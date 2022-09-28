# print the type of the variable
function var::type() {
    local signature=$(declare -p "$1" 2>/dev/null)
    if [ -n "$signature" ]; then
        signature="${signature#*'declare -'}"
        signature="${signature%%' '*}"

        case "$signature" in
            *'a'*) signature='arr' ;;
            *'A'*) signature='map' ;;
            *'i'*) signature='int' ;;
            *'-'*) signature='str' ;;
            *'n'*) signature='ref' ;;
            *'x'*) signature='env' ;;
        esac

        echo $signature
        return
    fi
    false
}

function int.to_string() {
    local -n integer=$1
    printf 'int %s = %s\n' "$1" "$integer"
}

function env.to_string() {
    local -n env=$1
    printf "export %s = '%s'\n" "$1" "$env"
}

function ref.to_string() {
    local signature=$(declare -p "$1" 2>/dev/null)
    if [[ "$signature" =~ $1=\"(.*)\" ]]; then
        local ref="${BASH_REMATCH[1]}"
        printf "ref %s = '%s'\n" "$1" "$ref"
        if declare -p "$ref" &>/dev/null; then
            "$(var::type "$ref")".to_string "$ref"
        else
            printf 'undefined variable %s\n' "$ref"
        fi
        return
    fi
    false
}
