# faster git function
# _get_git_branch(out branch)
# save shrinked path to val.
# if the parameter is missing, print to stdout
# _get_git_branch
# _get_git_branch branch && echo "$branch"
function git::branch() {
    local _head_file _head
    local _dir="$PWD"

    while [[ -n "$_dir" ]]; do
        _head_file="$_dir/.git/HEAD"
        if [[ -f "$_dir/.git" ]]; then
            read -r _head_file < "$_dir/.git" && _head_file="$_dir/${_head_file#gitdir: }/HEAD"
        fi
        [[ -e "$_head_file" ]] && break
        _dir="${_dir%/*}"
    done

    local branch=''
    if [[ -e "$_head_file" ]]; then
        read -r _head < "$_head_file" || return
        case "$_head" in
            ref:*) branch="${_head#ref: refs/heads/}" ;;
            "") ;;
            # HEAD detached
            *) branch="${_head:0:9}" ;;
        esac
        if [ "$#" -eq 1 ]; then
            printf -v "$1" '%s' "$branch"
        else
            printf '%s' "$branch"
        fi
        return 0
    fi

    return 128
}

# tracked: git diff --no-ext-diff --quiet --cached HEAD -- # Only tracked