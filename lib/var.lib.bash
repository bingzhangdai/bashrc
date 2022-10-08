# print the type of the variable
function decltype() {
    local _decl_sig=$(declare -p "$1" 2>/dev/null)
    if [[ -n "$_decl_sig" ]]; then
        _decl_sig="${_decl_sig#*'declare -'}"
        _decl_sig="${_decl_sig%%' '*}"

        case "$_decl_sig" in
            *'a'*) _decl_sig='arr' ;;
            *'A'*) _decl_sig='map' ;;
            *'i'*) _decl_sig='int' ;;
            *'-'*) _decl_sig='str' ;;
            *'n'*) _decl_sig='ref' ;;
            *'x'*) _decl_sig='env' ;;
        esac

        echo $_decl_sig
        return
    fi
    false
}

function var::list_all() {
    # compgen -v does not list all variable
    #   e.g. `declare -a array; compgen -v` does not include `array`
    # on mac, brew install grep
    declare -p | grep -Po '^declare -[a-zA-Z\-]+ \K[a-zA-Z_][a-zA-Z_0-9]*'
}

# region int

function int.to_string() {
    local -n integer=$1
    printf 'int %s = %s\n' "$1" "$integer"
}

alias int='declare -i'

# endregion

# region arr

alias arr='declare -a '

function arr.contains() {
    local -n _arr_var=$1
    local _arr_val=$2
    local _arr_v
    for _arr_v in "${_arr_var[@]}"; do
        [[ "$_arr_v" == "$_arr_val" ]] && return
    done
    false
}

function arr.add() {
    local -n _arr_var=$1
    local _arr_val=$2
    _arr_var[${#_arr_var[@]}]="$_arr_val"
}

function arr::is_array() {
    local _arr_sig=$(declare -p "$1" 2>/dev/null)
    [[ "$_arr_sig" =~ declare\ -.*a.*\ $1 ]]
}

function arr.to_string() {
    local -n _arr_var=$1
    arr _arr_quote

    local _arr_i
    for _arr_i in "${_arr_var[@]}"; do
        arr.add _arr_quote "'$_arr_i'"
    done

    int _arr_count=$(( ${#1} + 9 )) _arr_width=${COLUMNS-80}
    for _arr_i in "${_arr_quote[@]}"; do
        _arr_count=$(( _arr_count + ${#_arr_i} + 2 ))
    done

    local _arr_val
    if (( _arr_count > _arr_width )); then
        _arr_val=$(str::join -d ',\n    ' "${_arr_quote[@]}")
        _arr_val="\n    $_arr_val\n"
    elif [[ ${#_arr_quote[@]} -ne 0 ]]; then
        _arr_val=$(str::join -d ', ' "${_arr_quote[@]}")
        _arr_val=" $_arr_val "
    fi

    printf 'arr %s = {%b}\n' "$1" "$_arr_val"
}

function arr::_completion() {
    local CURRENT_PROMPT="${COMP_WORDS[COMP_CWORD]}"

    # local _arr_candidates=( $(compgen -v) )
    local _arr_candidates=( $(var::list_all) )

    local _arr_i
    for _arr_i in "${_arr_candidates[@]}"; do
        if ! arr::is_array $_arr_i; then
            continue
        fi

        if [[ -z "$CURRENT_PROMPT" ]]; then
            [[ "$_arr_i" != _* ]] && arr.add COMPREPLY "$_arr_i"
        else
            [[ "${_arr_i,,}" == ${CURRENT_PROMPT,,}* ]] && arr.add COMPREPLY "$_arr_i"
        fi
    done
}
complete -F arr::_completion arr.contains arr.add arr.to_string

# endregion

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
            "$(decltype "$ref")".to_string "$ref"
        else
            printf 'undefined variable %s\n' "$ref"
        fi
        return
    fi
    false
}

function var::_complete() {
    local CURRENT_PROMPT="${COMP_WORDS[COMP_CWORD]}"

    # local _arr_candidates=( $(compgen -v) )
    local _arr_candidates=( $(var::list_all) )

    local _arr_i
    for _arr_i in "${_arr_candidates[@]}"; do
        if [[ -z "$CURRENT_PROMPT" ]]; then
            [[ "$_arr_i" != _* ]] && arr.add COMPREPLY "$_arr_i"
        else
            [[ "${_arr_i,,}" == ${CURRENT_PROMPT,,}* ]] && arr.add COMPREPLY "$_arr_i"
        fi
    done
}

complete -F var::_complete arr::is_array
