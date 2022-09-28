# find out if an array contains a value
function arr.contains() {
    local -n arr=$1
    local val=$2
    local v
    for v in "${arr[@]}"; do
        [[ "$v" == "$val" ]] && return 0
    done
    false
}

function arr.add() {
    local -n arr=$1
    local val=$2
    arr[${#arr[@]}]="$val"
}

function arr::is_array() {
    local signature=$(declare -p "$1" 2>/dev/null)
    [[ "$signature" =~ declare\ -.*a.*\ $1 ]]
}

function arr.to_string() {
    local -n arr=$1
    if [ "${#arr[@]}" -eq 0 ]; then
        printf 'array %s = {}\n' "$1"
        return
    fi
    local val=$(str::join -d ', ' "${arr[@]}")
    printf 'array %s = { %s }\n' "$1" "$val"
}

alias array='declare -a '
