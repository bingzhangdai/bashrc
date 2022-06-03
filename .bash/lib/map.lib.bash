
function map::contains_key() {
    local key=$1
    local -n map=$2
    [ "${map[$key]+isset}" ]
}

function map::is_map() {
    local signature=$(declare -p "$1" 2>/dev/null)
    [[ "$signature" =~ declare\ -.*A.*\ $1 ]]
}

alias map='declare -A '
