
function map.contains_key() {
    local -n map=$1
    local key=$2
    [ "${map[$key]+isset}" ]
}

function map::is_map() {
    local signature=$(declare -p "$1" 2>/dev/null)
    [[ "$signature" =~ declare\ -.*A.*\ $1 ]]
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

alias map='declare -A '
