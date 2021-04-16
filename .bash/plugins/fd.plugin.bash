pragma_once

command -v fdfind > /dev/null && alias fd=fdfind

command -v fd > /dev/null || return

## default to exclude .git
FD_OPTIONS="--follow --exclude .git"
