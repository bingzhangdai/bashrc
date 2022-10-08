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

# region env

alias env='declare -x'

function env.to_string() {
    ref _env_var=$1
    printf "env %s = '%s'\n" "$1" "$_env_var"
}

# endregion

# region ref

alias ref='declare -n'

function ref.to_string() {
    local _ref_sig=$(declare -p "$1" 2>/dev/null)
    if [[ "$_ref_sig" =~ $1=\"(.*)\" ]]; then
        local _ref_var="${BASH_REMATCH[1]}"
        printf "ref %s = '%s'\n" "$1" "$_ref_var"
        if declare -p "$_ref_var" &>/dev/null; then
            "$(decltype "$_ref_var")".to_string "$_ref_var"
        else
            printf 'undefined variable %s\n' "$_ref_var"
        fi
        return
    fi
    false
}

# endregion

# region int

alias int='declare -i'

function int.to_string() {
    ref _int_var=$1
    printf 'int %s = %s\n' "$1" "$_int_var"
}

# endregion

# region arr

alias arr='declare -a '

function arr.contains() {
    ref _arr_var=$1
    local _arr_val=$2
    local _arr_v
    for _arr_v in "${_arr_var[@]}"; do
        [[ "$_arr_v" == "$_arr_val" ]] && return
    done
    false
}

function arr.add() {
    ref _arr_var=$1
    local _arr_val=$2
    _arr_var[${#_arr_var[@]}]="$_arr_val"
}

function arr::is_array() {
    local _arr_sig=$(declare -p "$1" 2>/dev/null)
    [[ "$_arr_sig" =~ declare\ -.*a.*\ $1 ]]
}

function arr.to_string() {
    ref _arr_var=$1
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

# region map

alias map='declare -A '

function map.contains_key() {
    ref _map_var=$1
    local _map_key=$2
    [[ -n "$_map_key" ]] && [[ "${_map_var[$_map_key]+isset}" ]]
}

function map::is_map() {
    local _map_sig=$(declare -p "$1" 2>/dev/null)
    [[ "$_map_sig" =~ declare\ -.*A.*\ $1 ]]
}

function map.to_string() {
    local -n map=$1
    local key val
    if [ "${#map[@]}" -eq 0 ]; then
        printf 'map %s = {}\n' "$1"
        return
    fi
    printf 'map %s = {\n' "$1"
    for key in "${!map[@]}"; do
        val="${map[$key]}"
        printf '    %s: %s\n' "$key" "$val"
    done
    printf '}\n'
}

function map::_completion() {
    local CURRENT_PROMPT="${COMP_WORDS[COMP_CWORD]}"

    local _map_candidates=( $(var::list_all) )

    local _map_i
    for _map_i in "${_map_candidates[@]}"; do
        if ! map::is_map $_map_i; then
            continue
        fi

        if [[ -z "$CURRENT_PROMPT" ]]; then
            [[ "$_map_i" != _* ]] && arr.add COMPREPLY "$_map_i"
        else
            [[ "${_map_i,,}" == ${CURRENT_PROMPT,,}* ]] && arr.add COMPREPLY "$_map_i"
        fi
    done
}
complete -F map::_completion map.contains_key map.to_string

# endregion

function var::_complete() {
    local CURRENT_PROMPT="${COMP_WORDS[COMP_CWORD]}"

    local _var_candidates=( $(var::list_all) )

    local _var_i
    for _var_i in "${_var_candidates[@]}"; do
        if [[ -z "$CURRENT_PROMPT" ]]; then
            [[ "$_var_i" != _* ]] && arr.add COMPREPLY "$_var_i"
        else
            [[ "${_var_i,,}" == ${CURRENT_PROMPT,,}* ]] && arr.add COMPREPLY "$_var_i"
        fi
    done
}

complete -F var::_complete arr::is_array
