pragma_once
# z - jump around
# https://github.com/rupa/z

zsh_plugin="${_DOT_BASH_CACHE}/z.plugin.bash"

# download rupa/z if not exist
if [[ ! -e "$zsh_plugin" ]]; then
    echo "Downloading rupa/z ..."
    util_download "https://raw.githubusercontent.com/rupa/z/master/z.sh" "$zsh_plugin"
    [[ $? -ne 0 ]] && log ERROR "download rupa/z failed" && return 1
    log "download rupa/z succeeded"
fi

builtin source $zsh_plugin

if include fzf; then
    unalias z 2> /dev/null
    function z() {
        if [ $# -gt 0 ]; then
            _z "$@"
        else
            cd "$(_z -l 2>&1 | fzf --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }" | sed 's/^[0-9,.]* *//')"
        fi
    }
fi

unset zsh_plugin