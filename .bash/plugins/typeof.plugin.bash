# get the type of variable, function, shell builtin, etc.

    # Options:
    #   -f        restrict action or display to function names and definitions
    #   -F        restrict display to function names only (plus line number and
    #             source file when debugging)
    #   -g        create global variables when used in a shell function; otherwise
    #             ignored
    #   -I        if creating a local variable, inherit the attributes and value
    #             of a variable with the same name at a previous scope
    #   -p        display the attributes and value of each NAME
    
    # Options which set attributes:
    #   -a        to make NAMEs indexed arrays (if supported)
    #   -A        to make NAMEs associative arrays (if supported)
    #   -i        to make NAMEs have the `integer' attribute
    #   -n        make NAME a reference to the variable named by its value
    #   -x        to make NAMEs export

typeof () {
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

        echo "${attributes[@]}"

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
