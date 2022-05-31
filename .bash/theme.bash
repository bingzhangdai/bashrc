function _show_pwd() {
    local format='%s'
    format="${1:-$format}"
    local path="${2:-$PWD}"
    path=${path/#$HOME/\~}
    local _short_path
    if [ -n "$eliminate_ambiguity" ]; then
        shrink_path -d -e _short_path "$path"
    else
        shrink_path -e _short_path "$path"
    fi
    printf -- "$format" "$_short_path"
}

# function _show_git() {
#     local format='[%s]'
#     format="${1:-$format}"
#     (! command -v git > /dev/null) && return $exit
#     # "git symbolic-ref --short -q HEAD" is 40% faster than "git rev-parse --abbrev-ref HEAD"
#     local _git_branch=$(git symbolic-ref --short HEAD 2>&1)
#     [[ "$_git_branch" = *"fatal: not a git repository"* ]] && return $exit
#     [[ "$_git_branch" = *"fatal: ref HEAD is not a symbolic ref"* ]] && _git_branch=$(git rev-parse --short HEAD 2> /dev/null)
#     [[ -z "$_git_branch" ]] && return $exit
#     printf -- "$format" "$(shrink_path ${_git_branch})"
# }

# pure Bash version
function _show_git() {
    local format='[%s]'
    format="${1:-$format}"
    local _git_branch
    _get_git_branch _git_branch
    [[ -z "$_git_branch" ]] && return $exit
    local _short_branch
    shrink_path -e _short_branch "${_git_branch}"
    printf -- "$format" "$_short_branch"
}

# _get_git_branch(out branch)
# save shrinked path to val.
# if the parameter is missing, print to stdout
# _get_git_branch
# _get_git_branch branch && echo "$branch"
function _get_git_branch() {
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

# Special prompt variable: https://ss64.com/bash/syntax-prompt.html
hostname='\h'
if _is_in_wsl; then
    if [[ -n "$WSL_DISTRO_NAME" ]]; then
        hostname="$WSL_DISTRO_NAME"
    else
        hostname="${NAME:-WSL}-$(_get_wsl_version)"
    fi
fi

# ternary_operator(cond, out1, out2)
# cond == 0 ? printf out1 : printf out2
function ternary_operator() {
    [ "$1" -eq 0 ] && printf "$2" || printf "$3"
}

# colors can be found in lib/color.lib.bash
if [ "$_color_prompt" = yes ]; then
     # username@hostname
    if [[ "$UID" == "0" ]]; then
        PS1="\[${ORANGE}\]\u\[${NONE}\]@\[\$(no_return_call ternary_operator \\j \${ORANGE} \${RED})\]${hostname}"
    else
        PS1="\[${GREEN}\]\u\[${NONE}\]@\[\$(no_return_call ternary_operator \\j \${GREEN} \${RED})\]${hostname}"
    fi
    PS1+="\[${NONE}\]:"
    # \w
    if [ -n "$fish_prompt" ]; then
        PS1+='$(no_return_call _show_pwd "\[${YELLOW}\]%s" "\w")' # _show_pwd
    else
        PS1+='\[${YELLOW}\]\w' # _show_pwd
    fi
    # git branch
    if [ -n "$git_prompt" ]; then
        PS1+='$(no_return_call _show_git "\[${BLACK_B}\](%s)")'
    fi
    PS1+='$(ternary_operator $? "\[${NONE}\]" "\[${RED}\]")\$\[${NONE}\] '
    PS2="\[${YELLOW}\]${PS2}\[${NONE}\]"
else
    PS1="\u@${hostname}"
    # \w
    if [ -n "$fish_prompt" ]; then
        PS1+=':$(no_return_call _show_pwd "%s" "\w")'
    else
        PS1+='\w' # _show_pwd
    fi
    # git branch
    if [ -n "$git_prompt" ]; then
        PS1+='$(no_return_call _show_git "(%s)")'
    fi
    # PS1+='$(exit=$?; [[ "$exit" == "0" ]] || printf ":$exit")'
    PS1+='\$ '
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    # PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    PS1="\[\e]0;\u@${hostname}: \W\a\]$PS1"
    ;;
*)
    ;;
esac

unset hostname
