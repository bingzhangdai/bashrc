function _show_pwd() {
    local format='%s'
    format="${1:-$format}"
    local path="${2:-$PWD}"
    # case insensitive replace prefix
    if os::is_wsl && str.starts_with path '/mnt/c' || os::is_mac; then
        : ${path,,}
        if str.starts_with _ ${HOME,,} ; then
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

ps_symbol='\$'
# if os::is_mac; then
#     ps_symbol='\[\]'
# fi

# _ternary_op(cond, out1, out2)
# cond == 0 ? printf out1 : printf out2
function _ternary_op() {
    [ "$1" -eq 0 ] && printf "$2" || printf "$3"
}

# colors can be found in lib/color.lib.bash
if [ "$_color_prompt" = yes ]; then
     # username@hostname
    if [[ "$UID" == "0" ]]; then
        : ORANGE
    else
        : GREEN
    fi
    PS1="\[\${$_}\]\u\[\$(clean_call _ternary_op \\j \${NONE} \${RED})\]@\[\${$_}\]${hostname}"
    PS1+='\[$(clean_eval "[[ -w \w ]]; _ternary_op \\$? \\${NONE} \\${RED}" )\]:'
    # \w
    if [ -n "$fish_prompt" ]; then
        PS1+='$(clean_call _show_pwd "\[${YELLOW}\]%s" "\w")' # _show_pwd
    else
        PS1+='\[${YELLOW}\]\w' # _show_pwd
    fi
    # git branch
    if [ -n "$git_prompt" ]; then
        PS1+='$(clean_call _show_git "\[${BLACK_B}\](%s)")'
    fi
    PS1+="\[\$(_ternary_op \$? \${NONE} \${RED})\]$ps_symbol\[\${NONE}\] "
    PS2="\[${YELLOW}\]${PS2}\[${NONE}\]"
else
    PS1="\u@${hostname}"
    # \w
    if [ -n "$fish_prompt" ]; then
        PS1+=':$(clean_call _show_pwd "%s" "\w")'
    else
        PS1+=':\w' # _show_pwd
    fi
    # git branch
    if [ -n "$git_prompt" ]; then
        PS1+='$(clean_call _show_git "(%s)")'
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
unset ps_symbol
