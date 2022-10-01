
function type::is_function() {
    declare -F "$1" > /dev/null
}

function type::pprint() {
    local ret=1

    # print variable
    local _type=$(var::type "$1")
    if [ -n "$_type" ] && type::is_function "$_type".to_string; then
        "$_type".to_string "$1"
        ret=0
    fi

    # print function
    if type::is_function "$1"; then
        declare -f $1
        ret=0
    fi

    return $ret
}

alias pprint=type::pprint

function type::_pprint_complete() {
    local CURRENT_PROMPT="${COMP_WORDS[COMP_CWORD]}"

    local candidates=()
    # varibale
    candidates=( ${candidates[@]} $(compgen -v) )
    # function
    candidates=( ${candidates[@]} $(compgen -A function) )

    local i
    if [[ -z "$CURRENT_PROMPT" ]]; then
        # ignore the candidates starting with underscore
        for i in "${candidates[@]}"; do
            [[ "$i" != _* ]] && arr.add COMPREPLY "$i"
        done
    else
        # ignore case
        for i in "${candidates[@]}"; do
            [[ "${i,,}" == ${CURRENT_PROMPT,,}* ]] && arr.add COMPREPLY "$i"
        done
    fi
}

complete -F type::_pprint_complete type::pprint pprint

# # TODO: tab completion: https://metacpan.org/pod/Complete::Bash
# # https://stackoverflow.com/questions/49068871/override-bash-completion-for-every-command
# # https://opensource.apple.com/source/bash/bash-44.3/bash/examples/complete/complete-examples.auto.html
# # call the function like member function
# if declare -F command_not_found_handle > /dev/null; then
#     eval "$(echo "type_orig_command_not_found_handle()"; declare -f command_not_found_handle | tail -n +2)"
# else
#     function type_orig_command_not_found_handle() {
#         if [ -x /usr/lib/command-not-found ]; then
#             /usr/lib/command-not-found -- "$1";
#             return $?;
#         else
#             if [ -x /usr/share/command-not-found/command-not-found ]; then
#                 /usr/share/command-not-found/command-not-found -- "$1";
#                 return $?;
#             else
#                 printf "%s: command not found\n" "$1" 1>&2;
#                 return 127;
#             fi
#         fi
#     }
# fi

# command_not_found_handle() {
#     if [ $# -eq 1 ] && type::pprint "$1" 2>/dev/null; then
#         return
#     fi

#     type_orig_command_not_found_handle "$@"
# }

# get the type of variable, function, shell builtin, etc.
# usage:
#   typeof variable_name
# exmaple:
#   typeof PATH -> environment variable
#   typeof typeof -> function
type::typeof () {
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
            *'x'*) attributes+=('environment') ;;
        esac

        local variable_attributes;
        str::join -o variable_attributes "${attributes[@]}" 'variable'
        values+=("$variable_attributes")
    fi

    # other types
    signature=$(type -t "$1")
    if [ -n "$signature" ]; then
        case "$signature" in
            'keyword') signature='shell keyword' ;;
            'builtin') signature='shell builtin' ;;
            'file') signature="executable file ($(which $1))" ;;
        esac

        values+=("$signature")

        if [ "${values[-1]}" != 'function' ] && declare -F "$1" > /dev/null; then
            values+=('function')
        fi

        if ! [[ "${values[-1]}" = *'executable file'* ]] && type -P "$1" > /dev/null; then
            values+=("executable file ($(which $1))")
        fi
    fi

    if [ "${#values[@]}" != 0 ]; then
        str::join -d ', ' "${values[@]}"
    else
        echo 'unknown'
        false
    fi
}

alias typeof='type::typeof'

# compgen
# -a means Names of alias
# -b means Names of shell builtins
# -c means Names of all commands
# -d means Names of directory
# -e means Names of exported shell variables
# -f means Names of file and functions
# -g means Names of groups
# -j means Names of job
# -k means Names of Shell reserved words
# -s means Names of service
# -u means Names of userAlias names
# -v means Names of shell variables
