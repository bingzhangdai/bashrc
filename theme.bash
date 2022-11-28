# Usage: _get_short_path output_var path
function _get_short_path() {
    local path=$2
    # case insensitive replace prefix
    if os::is_mac || { os::is_wsl && str.starts_with path "$WSL_AUTOMOUNT_ROOT"; }; then
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
    printf -v "$1" -- "$_short_path"
}

# Usage: _get_short_git_branch output_var
function _get_short_git_branch() {
    local _git_branch
    git::branch -o _git_branch 2> /dev/null
    local _short_branch
    path::shrink -o _short_branch "${_git_branch}"
    printf -v "$1" -- "$_short_branch"
}

# Special prompt variable: https://ss64.com/bash/syntax-prompt.html
hostname='\h'
if os::is_wsl; then
    hostname=${WSL_NETWORK_HOSTNAME}
    : "${hostname:=$WSL_DISTRO_NAME}"
    : "${hostname:="${NAME:-WSL}-$(os::wsl_version)"}"
fi

if [[ "$color_prompt" == yes ]]; then
    [[ "$UID" == "0" ]] && : ${ORANGE} || : ${GREEN}
    _PROMPT_USER_COLOR=$_
    _PROMPT_RETURN_CODE_COLOR=
    _PROMPT_JOBS_COLOR=$NONE
    _PROMPT_BATTERY_COLOR=
    _PROMPT_PATH_COLOR=
    _PROMPT_GIT_COLOR=${BLACK_B}
fi
_PROMPT_PATH=
_PROMPT_GIT=
function _generate_prompt() {
    local _exit=$?
    if [[ "$color_prompt" == yes ]]; then
        [[ "$_exit" == 0 ]] && : ${NONE} || : ${RED}; _PROMPT_RETURN_CODE_COLOR=$_
        # [[ -n "$(jobs -p)" ]] && : ${RED} || : ${NONE}; _PROMPT_JOBS_COLOR=$_
        battery::is_low && : ${RED} || : ${_PROMPT_USER_COLOR}; _PROMPT_BATTERY_COLOR=$_
        [[ -w "$PWD" ]] && : ${YELLOW} || : ${RED}; _PROMPT_PATH_COLOR=$_
    fi
    if [[ -n "$fish_prompt" ]]; then
        _get_short_path _PROMPT_PATH "$PWD"
    else
        _PROMPT_PATH=$PWD
    fi
    if [[ -n "$git_prompt" ]]; then
        _get_short_git_branch _PROMPT_GIT
    fi
    return $_exit
}
_generate_prompt
PROMPT_COMMAND="_generate_prompt;$PROMPT_COMMAND"

# colors can be found in lib/color.lib.bash
if [[ "$color_prompt" == yes ]]; then
     # username@hostname
    PS1='\[${_PROMPT_USER_COLOR}\]\u\[\033[$((\j?31:0))m\]@\[${_PROMPT_BATTERY_COLOR}\]'"${hostname}"
    # :
    PS1+='\[${NONE}\]:\[$_PROMPT_PATH_COLOR\]${_PROMPT_PATH}'
    # git branch
    if [[ -n "$git_prompt" ]]; then
        PS1+='\[${_PROMPT_GIT_COLOR}\]${_PROMPT_GIT:+($_PROMPT_GIT)}'
    fi
    PS1+='\[${_PROMPT_RETURN_CODE_COLOR}\]\$\[${NONE}\] '
    PS2="\[${YELLOW}\]${PS2}\[${NONE}\]"
else
    PS1="\u@${hostname}:\${_PROMPT_PATH}\${_PROMPT_GIT}\$ "
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
