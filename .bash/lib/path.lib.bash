# deduplicate the variable separated by ':' while keeping the first occurrence.
# example:
#   dedup PATH
function dedup() {
    local -n NEW_PATH="$1"
    IFS=":" read -ra OLD_PATH <<< $NEW_PATH
    NEW_PATH=${OLD_PATH[0]}
    for p in ${OLD_PATH[@]:1}; do
        [ -z "$p" ] && continue;
        case ":$NEW_PATH:" in
            *":$p:"*)
                ;; # already exists
            *)
                NEW_PATH=$NEW_PATH:"$p" ;;
        esac
    done
}
