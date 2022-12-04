[[ -r /etc/debian_chroot ]] && debian_chroot="$(</etc/debian_chroot)"

function term::set_title() {
    [[ "$PS1" =~ \\\[\\e\]0\;.*\\a\\\](.*) ]] && PS1=${BASH_REMATCH[1]}
    PS1='\[\e]0;'"$1"'\a\]'"$PS1"
}

function term::is_ssh() {
    [[ -n "${SSH_CLIENT-}${SSH2_CLIENT-}${SSH_TTY-}" ]]
}

function term::is_telnet() {
    [[ -n ${REMOTEHOST-} ]]
}

function term::is_local() {
    ! term::is_ssh && ! term::is_telnet
}

function term::x() {
    local _x_pos
    term::_get_cursor_pos _x_pos _
    printf '%d\n' "$_x_pos"
}

function term::y() {
    local _y_pos
    term::_get_cursor_pos _ _y_pos
    printf '%d\n' "$_y_pos"
}

function term::_get_cursor_pos() {
    local _x _y
    IFS='[;' read -p $'\e[6n' -d R -rs _ _y _x _
    printf -v "$1" "$_x"
    printf -v "$2" "$_y"
}
