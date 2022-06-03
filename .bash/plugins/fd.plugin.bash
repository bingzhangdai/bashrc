command -v fdfind > /dev/null && alias fd=fdfind

if ! command -v fd > /dev/null; then
    logger::log INFO "command fdfind/fd cannot be found, skipped."
    false
    return
fi

## default to exclude .git
FD_OPTIONS="--follow --exclude .git"
