# find out if an array contains a value
function array::contains() {
    local val=$1
    shift
    local v
    for v in "$@"; do
        [[ "$v" == "$val" ]] && return 0
    done
    false
}
