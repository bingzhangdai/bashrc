# short and human-readable directory listing
alias dud='du -d 1 -h | sort -h'

# short and human-readable file listing
alias duf='du -sh * | sort -h | while read -r size file; do printf "${size}\t"; [[ -d "$file" ]] && printf "./${file}/\n" || printf -- "${file}\n"; done'

# quickly search for file
function _qfind() {
    while [ $# -gt 0 ]; do
        # printf -- '%s\n' "${RED}${1}${NONE}:"
        if command -v fd > /dev/null; then
            fd --type f --hidden ${FD_OPTIONS} --glob "$1" .
        else
            find . -type d \( -name .git \) -prune -false -o -iname "$1"
        fi
        shift
    done
    if [ -n "$_qf_noglob" ]; then
        set +o noglob
        unset _qf_noglob
    fi
}
# temporarily stop shell wildcard character expansion
# restore expansion in _qfind function
alias qfind='[[ ! -o noglob ]] && _qf_noglob=false && set -o noglob; _qfind'

# regex find
function _rfind() {
    while [ $# -gt 0 ]; do
        # printf -- '%s\n' "${RED}${1}${NONE}:"
        if command -v fd > /dev/null; then
            fd --type f --hidden ${FD_OPTIONS} "$1" .
        else
            find . -type d \( -name .git \) -prune -false -o -iregex "$1"
        fi
        shift
    done
    if [ -n "$_rf_noglob" ]; then
        set +o noglob
        unset _rf_noglob
    fi
}

alias rfind='[[ ! -o noglob ]] && _rf_noglob=false && set -o noglob; _rfind'