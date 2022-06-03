
function map::contains_key() {
    local key=$1
    local -n map=$2
    [ "${map[$key]+isset}" ]
}

alias map='declare -A '
