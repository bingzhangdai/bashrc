function ini::filter_by_section() {
    local _line _section
    while IFS=$'\n' read -r _line; do
        _line=${_line%%;*}
        _line=${_line%%#*}
        [[ -z "$line" ]] && continue
        [[ "$_line" =~ ^\[.*\]$ ]] && _section=${BASH_REMATCH[1]} && continue
        [[ "$_section" == "$1" ]] && printf '%s\n' "$line"
    done
}

function ini::get_value_by_key() {
    local _line
    while IFS=$'\n' read -r _line; do
        _line=${_line%%;*}
        _line=${_line%%#*}
        [[ -z "$_line" ]] && continue
        [[ "$_line" =~ $1[[:space:]]*=[[:space:]]*([^[:space:]]*) ]] && printf '%s\n' "${BASH_REMATCH[1]}"
    done
}
