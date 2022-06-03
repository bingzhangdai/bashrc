# bash completion support for core Git.

command -v git > /dev/null || return

_git_completion="${_DOT_BASH_CACHE}/git.completion.bash"

# try to find git-completion in installation dir
if [[ -f /usr/share/bash-completion/completions/git ]]; then
    _git_completion='/usr/share/bash-completion/completions/git'
elif [[ ! -e "$_git_completion" ]]; then
    logger::log "Downloading git-completion.bash ..."
    util_download "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash" "$_git_completion"
    [[ $? -ne 0 ]] && logger::log ERROR "download git-completion.bash failed" && return 1
    logger::log "Download git-completion.bash succeeded"
fi

source $_git_completion

unset _git_completion
