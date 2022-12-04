function _setup_fzf_using_package() {
    # Auto-completion
    local completions="/usr/share/doc/fzf/examples/completion.bash"
    if [ -e "$completions" ]; then
        builtin source $completions 2> /dev/null || return
    # old location
    elif [ -e '/usr/share/bash-completion/completions/fzf' ]; then
        builtin source /usr/share/bash-completion/completions/fzf || return
    else
        return
    fi

    # Key bindings
    local key_bindings="/usr/share/doc/fzf/examples/key-bindings.bash"
    [ -e "$key_bindings" ] && builtin source $key_bindings
}

function _setup_fzf_using_base_dir() {
    if [ -f ~/.fzf.bash ]; then
        builtin source ~/.fzf.bash
    elif [ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash ]; then
        builtin source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash
    else
        false
    fi
}

function _setup_fzf_using_homebrew() {
    local auto_completion="$_BREW_PREFIX"/opt/fzf/shell/completion.bash
    local key_bindings="$_BREW_PREFIX"/opt/fzf/shell/key-bindings.bash
    if [ -r $auto_completion ] && [ -r $key_bindings ]; then
        builtin source $auto_completion
        builtin source $key_bindings
    else
        false
    fi
}

if ! _setup_fzf_using_package && ! _setup_fzf_using_base_dir && ! _setup_fzf_using_homebrew; then
    if command -v fzf > /dev/null; then
        # fzf installed from package manager, but _setup_fzf_using_package failed to properly config fzf
        logger.log ERROR "fzf setup failed."
    else
        logger.log INFO "command fzf cannot be found, skipped."
    fi
    unset -f _setup_fzf_using_package _setup_fzf_using_base_dir _setup_fzf_using_homebrew
    return 1
fi

if source fd.plugin.bash; then
    command -v fdfind > /dev/null && fd=fdfind
    export FZF_DEFAULT_COMMAND="${fd:-fd} --type f --type l --follow --hidden --exclude .git"
    export FZF_ALT_C_COMMAND="${fd:-fd} --type d --type l --follow --hidden --exclude .git 2> /dev/null"
    unset fd
    _fzf_compgen_path() {
        fd --hidden --follow --exclude ".git" . "$1"
    }
    _fzf_compgen_dir() {
        fd --type d --hidden --follow --exclude ".git" . "$1"
    }
fi

function fcd() {
    if command -v fd > /dev/null; then
        local dir=$(fd . ${1:-.} --type d --hidden --follow --exclude .git 2> /dev/null | fzf +m)
    else
        local dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf +m)
    fi
    local ex=$?
    [[ "$ex" -ne 0 ]] && return $ex
    cd "$dir"
}

os::is_mac && bind '"ç": "\ec"'

function _set_fzf_default_opts() {
    if command -v bat > /dev/null; then
        local cat='bat --color=always'
        local less='bat --style=numbers --paging=always'
    else
        local cat='cat'
        local less='less -f'
    fi
    export FZF_DEFAULT_OPTS="--height 50% -1 --reverse --multi --inline-info \
                            --preview='([[ -d {} ]] && ls -Al --color=always {}) || ([[ \$(file --mime {}) =~ binary ]] && stat {}) || $cat -n {} | head -100' \
                            --preview-window='right:hidden:wrap' \
                            --bind='f2:toggle-preview,ctrl-p:execute($less -n {}),ctrl-v:execute(vim -n {}),ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept'"
}

_set_fzf_default_opts
unset -f _set_fzf_default_opts
