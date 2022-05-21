# deduplicate the variable separated by delimeter (default to ':') while keeping the first occurrence.
# usage:
#   dedeup var
#   dedeup var delimeter
# example:
#   dedup PATH
#   VAR="hello world hello bingzhang" && dedup VAR ' ' && echo $VAR
function dedup() {
    local -n NEW_PATH="$1"
    local delimiter="${2:-:}"
    IFS="$delimiter" read -ra OLD_PATH <<< $NEW_PATH
    NEW_PATH=${OLD_PATH[0]}
    for p in ${OLD_PATH[@]:1}; do
        [ -z "$p" ] && continue;
        case "$delimiter$NEW_PATH$delimiter" in
            *"$delimiter$p$delimiter"*)
                ;; # already exists
            *)
                NEW_PATH=$NEW_PATH$delimiter$p ;;
        esac
    done
}
