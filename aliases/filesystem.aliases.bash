# short and human-readable directory listing
alias dud='du -d 1 -h | sort -h'

# short and human-readable file listing
alias duf='du -sh * | sort -h | while read -r size file; do printf "${size}\t"; [[ -d "$file" ]] && printf "./${file}/\n" || printf -- "${file}\n"; done'

# quickly search for file
function qfind() {
    # printf -- '%s\n' "${RED}${1}${NONE}:"
    if command -v fd > /dev/null; then
        fd --type f --hidden ${FD_OPTIONS} --glob "$1" .
    else
        find . -type d \( -name .git \) -prune -false -o -iname "$1"
    fi
}

# regex find
function rfind() {
    # printf -- '%s\n' "${RED}${1}${NONE}:"
    if command -v fd > /dev/null; then
        fd --type f --hidden ${FD_OPTIONS} "$1" .
    else
        find . -type d \( -name .git \) -prune -false -o -iregex "$1"
    fi
}
