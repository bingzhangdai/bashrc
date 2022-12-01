
function fun::is_function() {
    declare -F "$1" > /dev/null
}

# fun::rename FROM TO
function fun::rename() {
    eval "$(echo "$2()"; declare -f "$1" | tail -n +2)"
    unset -f "$1"
}

function fun.to_string() {
    :
}
