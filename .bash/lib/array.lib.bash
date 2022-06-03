# find out if an array contains a value
function array::contains() {
    local val=$1 array=$2
    local v
    for v in "${array[@]}"; do
        [[ "$v" == "$val" ]] && return 0
    done
    false
}

function array::is_array() {
    local -n array=$1
    [ "${array[0]+isset}" ]
    local signature=$(declare -p "$1" 2>/dev/null)
    [ -n "$signature" ]
    [[ "$signature" =~ declare\ -.*a.*\ $1=.* ]]
}

alias array='declare -a '
