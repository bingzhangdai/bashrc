function _show_pwd() {
    local format='%s'
    format="${1:-$format}"
    local path="${2:-$PWD}"
    # case insensitive replace prefix
    if os::is_wsl || os::is_mac; then
        local _tmp_path=${path,,}
        _tmp_path=${_tmp_path/#${HOME,,}}
        if [[ ${#_tmp_path} -ne ${#path} ]]; then
            path="~${path:${#HOME}}"
        fi
    else
        path=${path/#$HOME/\~}
    fi
    local _short_path
    if [ -n "$eliminate_ambiguity" ]; then
        path::shrink -d -o _short_path "$path"
    else
        path::shrink -o _short_path "$path"
    fi
    printf -- "$format" "$_short_path"
}

function _show_git() {
    local format='[%s]'
    format="${1:-$format}"
    local _git_branch
    git::branch -o _git_branch
    [[ -z "$_git_branch" ]] && return $exit
    local _short_branch
    path::shrink -o _short_branch "${_git_branch}"
    printf -- "$format" "$_short_branch"
}

# Special prompt variable: https://ss64.com/bash/syntax-prompt.html
hostname='\h'
if os::is_wsl; then
    if [[ -n "$WSL_DISTRO_NAME" ]]; then
        hostname="$WSL_DISTRO_NAME"
    else
        hostname="${NAME:-WSL}-$(os::wsl_version)"
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
        PS1+=':\w' # _show_pwd
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
