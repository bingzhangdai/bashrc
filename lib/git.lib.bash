function git::_branch() {
    local _head_file _head
    local _dir="$PWD"
    while [[ -n "$_dir" ]]; do
        _head_file="$_dir/.git/HEAD"
        if [[ -f "$_dir/.git" ]]; then
            read -r _head_file < "$_dir/.git" && _head_file="$_dir/${_head_file#gitdir: }/HEAD"
        fi
        [[ -f "$_head_file" ]] && break
        _dir="${_dir%/*}"
    done

    [[ -f "$_head_file" ]] || return
    read -r _head < "$_head_file" || return

    local branch=''
    case "$_head" in
        ref:*)
            branch="${_head#ref: refs/heads/}"
            ;;
        [0-9,a-z]*)
            # HEAD detached
            branch="${_head:0:9}"
            ;;
        *)
            >&2 printf '%s\n' 'fatal: not a git repository (or any of the parent directories): .git'
            return 128
            ;;
    esac

    printf -v "$1" '%s' "$branch"
}

# pure bash version of git branch, even faster than git symbolic-ref --short -q HEAD
#
# example:
#   git::branch -> 'master'
@create_public_fun git::_branch

# # slower version
# function git::branch() {
#     command -v git > /dev/null || return
#     # "git symbolic-ref --short -q HEAD" is 40% faster than "git rev-parse --abbrev-ref HEAD"
#     local branch=$(git symbolic-ref --short HEAD 2>&1)
#     if [[ "$branch" = *"fatal: not a git repository"* ]]; then
#         false
#         return
#     fi
#     if  [[ "$branch" = *"fatal: ref HEAD is not a symbolic ref"* ]]; then
#         branch=$(git rev-parse --short HEAD 2> /dev/null)
#     fi
#     [[ -n "$branch" ]] || return

#     if [ "$1" = '-o' ]; then
#         printf -v "$2" '%s' "$branch"
#     else
#         echo "$branch"
#     fi
# }
